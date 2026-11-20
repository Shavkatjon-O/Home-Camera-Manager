"""The site LAN interfaces discovery may use: real network interfaces, never Docker, container or VPN ones."""

import fcntl
import ipaddress
import socket
import struct
from dataclasses import dataclass

__all__ = [
    "SKIPPED_NETWORKS",
    "SKIPPED_PREFIXES",
    "SITE_NETWORKS",
    "LocalNetwork",
    "local_networks",
    "site_networks",
    "sweep_subnets",
]

SIOCGIFADDR = 0x8915
SIOCGIFNETMASK = 0x891B
SKIPPED_PREFIXES = (
    "lo",
    "docker",
    "br-",
    "veth",
    "virbr",
    "vmnet",
    "vboxnet",
    "cni",
    "flannel",
    "cali",
    "cilium",
    "kube",
    "podman",
    "tun",
    "tap",
    "wg",
    "wt",
    "tailscale",
    "zt",
    "nb-",
    "netbird",
    "ppp",
    "utun",
    "ipsec",
    "nordlynx",
    "proton",
)
SKIPPED_NETWORKS = tuple(
    ipaddress.ip_network(value) for value in ("127.0.0.0/8", "169.254.0.0/16", "100.64.0.0/10", "172.17.0.0/16")
)
SITE_NETWORKS = tuple(
    ipaddress.IPv4Network((address, prefix))
    for address, prefix in ((0x0A000000, 8), (0xAC100000, 12), (0xC0A80000, 16))
)
LARGEST_SWEEP = 24


@dataclass(frozen=True)
class LocalNetwork:
    """An IPv4 address of this machine with its network.

    Attributes:
        name: Interface name.
        interface: Address with prefix.
    """

    name: str
    interface: ipaddress.IPv4Interface

    @property
    def address(self) -> str:
        """str: The address without prefix."""
        return str(self.interface.ip)


def interface_address(name: str) -> ipaddress.IPv4Interface | None:
    """Read an interface's IPv4 address and netmask from the kernel.

    Args:
        name: Interface name.

    Returns:
        The address with prefix, or None for an interface without IPv4.
    """
    packed = struct.pack("256s", name[:15].encode())
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            address = socket.inet_ntoa(fcntl.ioctl(sock.fileno(), SIOCGIFADDR, packed)[20:24])
            netmask = socket.inet_ntoa(fcntl.ioctl(sock.fileno(), SIOCGIFNETMASK, packed)[20:24])
        except OSError:
            return None
    return ipaddress.IPv4Interface(f"{address}/{netmask}")


def local_networks() -> list[LocalNetwork]:
    """List this machine's IPv4 interfaces.

    Returns:
        Every interface with an IPv4 address, by name.
    """
    found = []
    for _, name in sorted(socket.if_nameindex(), key=lambda item: item[1]):
        interface = interface_address(name)
        if interface is not None:
            found.append(LocalNetwork(name=name, interface=interface))
    return found


def is_site_lan(network: LocalNetwork) -> bool:
    """Tell whether an interface looks like the site's LAN.

    Docker bridges, container and Kubernetes networks, VPN tunnels and loopback are not, and neither are
    loopback, link-local, carrier-grade NAT (used by VPN overlays) and Docker's default bridge addresses.

    Args:
        network: The interface.

    Returns:
        True for a real LAN interface with an RFC 1918 address.
    """
    name = network.name.lower()
    if name.startswith(SKIPPED_PREFIXES):
        return False
    address = network.interface.ip
    if any(address in skipped for skipped in SKIPPED_NETWORKS):
        return False
    return any(address in network for network in SITE_NETWORKS)


def site_networks(
    networks: list[LocalNetwork], allowed_interfaces: tuple[str, ...] = (), allowed_subnets: tuple[str, ...] = ()
) -> list[LocalNetwork]:
    """Pick the interfaces discovery uses.

    An explicit interface list wins over everything; otherwise an explicit subnet list keeps the interfaces inside
    those subnets; otherwise the filter keeps the real LAN interfaces.

    Args:
        networks: The machine's interfaces.
        allowed_interfaces: Interface names configured explicitly.
        allowed_subnets: Subnets configured explicitly.

    Returns:
        The interfaces to probe from and sweep.
    """
    if allowed_interfaces:
        return [network for network in networks if network.name in allowed_interfaces]
    if allowed_subnets:
        subnets = [ipaddress.ip_network(value, strict=False) for value in allowed_subnets]
        return [network for network in networks if any(network.interface.ip in subnet for subnet in subnets)]
    return [network for network in networks if is_site_lan(network)]


def sweep_subnets(networks: list[LocalNetwork], allowed_subnets: tuple[str, ...] = ()) -> list[str]:
    """Choose the subnets the port sweep covers.

    Configured subnets are used as given. Otherwise each interface's network is swept, narrowed to the /24 around
    the interface address when it is larger, so a sweep never runs across a large network.

    Args:
        networks: The interfaces discovery uses.
        allowed_subnets: Subnets configured explicitly.

    Returns:
        Subnets in CIDR form, without repeats.
    """
    if allowed_subnets:
        return list(dict.fromkeys(allowed_subnets))
    found = []
    for network in networks:
        subnet = network.interface.network
        if subnet.prefixlen < LARGEST_SWEEP:
            subnet = ipaddress.ip_network(f"{network.interface.ip}/{LARGEST_SWEEP}", strict=False)
        found.append(str(subnet))
    return list(dict.fromkeys(found))

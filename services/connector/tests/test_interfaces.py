import ipaddress

from connector_agent.interfaces import LocalNetwork, is_site_lan, site_networks, sweep_subnets


def net(name, value):
    return LocalNetwork(name=name, interface=ipaddress.IPv4Interface(value))


MACHINE = [
    net("lo", "127.0.0.1/8"),
    net("eth0", "192.168.1.10/24"),
    net("wlan0", "10.20.0.5/16"),
    net("docker0", "172.17.0.1/16"),
    net("br-3f2a1c", "172.31.251.1/24"),
    net("veth12ab", "169.254.10.1/16"),
    net("wt0", "100.92.4.7/16"),
    net("tailscale0", "100.101.2.3/32"),
    net("wg0", "10.8.0.2/24"),
    net("tun0", "10.9.0.2/24"),
    net("cni0", "10.42.0.1/24"),
    net("enp3s0", "203.0.113.4/24"),
    net("eth1", "172.17.5.2/16"),
]


def test_only_site_lan_interfaces_are_kept_by_default():
    assert [network.name for network in site_networks(MACHINE)] == ["eth0", "wlan0"]


def test_docker_container_and_vpn_interfaces_are_never_site_lan():
    names = {"docker0", "br-3f2a1c", "veth12ab", "wt0", "tailscale0", "wg0", "tun0", "cni0", "lo"}
    assert not any(is_site_lan(network) for network in MACHINE if network.name in names)


def test_public_carrier_grade_and_docker_default_addresses_are_skipped_whatever_the_name():
    assert not is_site_lan(net("enp3s0", "203.0.113.4/24"))
    assert not is_site_lan(net("eth2", "100.64.1.1/10"))
    assert not is_site_lan(net("eth1", "172.17.5.2/16"))


def test_an_explicit_interface_list_wins_even_over_the_filter():
    chosen = site_networks(MACHINE, allowed_interfaces=("br-3f2a1c",))
    assert [network.name for network in chosen] == ["br-3f2a1c"]


def test_an_explicit_subnet_list_keeps_the_interfaces_inside_it():
    chosen = site_networks(MACHINE, allowed_subnets=("10.20.0.0/16",))
    assert [network.name for network in chosen] == ["wlan0"]


def test_the_sweep_never_covers_more_than_a_24():
    assert sweep_subnets(site_networks(MACHINE)) == ["192.168.1.0/24", "10.20.0.0/24"]
    assert sweep_subnets([], ("192.168.7.0/24", "192.168.7.0/24")) == ["192.168.7.0/24"]

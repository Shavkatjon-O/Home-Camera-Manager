"""The running agent: pairing, go2rtc, heartbeats, configuration, discovery and the agent API."""

import asyncio
import logging
import time

import uvicorn

from connector_agent import __version__
from connector_agent.api import create_app
from connector_agent.backend import BackendClient, BackendError, Revoked
from connector_agent.cameras import CameraManager
from connector_agent.discovery import discover
from connector_agent.go2rtc import Go2rtc, go2rtc_config
from connector_agent.interfaces import local_networks, site_networks
from connector_agent.mdns import Advertiser
from connector_agent.pairing import pair, qr_svg, qr_text
from connector_agent.settings import Settings
from connector_agent.state import Pairing, Store

__all__ = ["Agent"]

logger = logging.getLogger(__name__)


class Agent:
    """Everything the connector runs, tied together.

    Attributes:
        settings: The settings.
        store: The encrypted store.
        go2rtc: The connector's go2rtc.
        cameras: The camera manager.
        pending: Device authorization waiting to be claimed, if any.
        advertiser: mDNS announcement of the pending pairing, if any.
        started: Monotonic start time.
        config_version: Digest of the camera list last applied.
        discovery_task: Running discovery, if any.
        last_discovery: Summary of the last discovery run.
    """

    def __init__(self, settings: Settings, store: Store | None = None, go2rtc: Go2rtc | None = None):
        """Create the agent from its settings.

        Args:
            settings: The settings.
            store: Store to use; one in the state folder when omitted.
            go2rtc: go2rtc manager to use; the configured binary when omitted.
        """
        self.settings = settings
        self.store = store or Store(settings.state_dir, settings.secret)
        self.go2rtc = go2rtc or Go2rtc(settings.go2rtc_binary, settings.go2rtc_api)
        self.cameras = CameraManager(self.store, self.go2rtc)
        self.pending: dict | None = None
        self.advertiser: Advertiser | None = None
        self.started = time.monotonic()
        self.config_version = ""
        self.discovery_task: asyncio.Task | None = None
        self.last_discovery: dict = {}

    def client(self, pairing: Pairing | None = None) -> BackendClient:
        """Build a backend client.

        Args:
            pairing: Pairing whose token to send, if any.

        Returns:
            The client.
        """
        return BackendClient(
            self.settings.backend_url, pairing.token if pairing else None, verify=self.settings.verify_tls
        )

    def networks(self):
        """List the interfaces discovery uses, after the site LAN filter and the configured allow lists.

        Returns:
            The interfaces.
        """
        return site_networks(local_networks(), self.settings.interfaces, self.settings.subnets)

    def pairing_qr_svg(self) -> str:
        """Draw the pending pairing link as a QR code.

        Returns:
            The SVG document.
        """
        return qr_svg(self.pending["verification_uri_complete"]) if self.pending else ""

    def shown(self, authorization: dict | None) -> None:
        """Show a new pairing code in the log, on the pairing page and over mDNS, or hide it.

        Args:
            authorization: The device authorization, or None when pairing ended.
        """
        self.pending = authorization
        if authorization is None:
            if self.advertiser is not None:
                asyncio.ensure_future(self.advertiser.stop())
                self.advertiser = None
            return
        logger.info(
            "Pairing code %s\n%s", authorization["user_code"], qr_text(authorization["verification_uri_complete"])
        )
        txt = {"code": authorization["user_code"], "version": __version__, "state": "pairing"}
        if self.advertiser is not None:
            self.advertiser.update(txt)
            return
        if not self.settings.mdns:
            return
        networks = self.networks()
        if not networks:
            logger.info("No site LAN interface to announce the pairing on")
            return
        advertiser = Advertiser(
            self.settings.name, self.settings.api_port, networks[0].address, txt, interface=networks[0].address
        )
        self.advertiser = advertiser
        asyncio.ensure_future(self.start_advertiser(advertiser))

    async def start_advertiser(self, advertiser: Advertiser) -> None:
        """Start announcing, logging a failure instead of stopping pairing.

        Args:
            advertiser: The announcement.
        """
        try:
            await advertiser.start()
        except OSError as exc:
            logger.warning("Announcing over mDNS failed: %s", exc)
            if self.advertiser is advertiser:
                self.advertiser = None

    async def paired(self) -> Pairing:
        """Return the stored pairing, or pair now.

        Returns:
            The pairing.
        """
        stored = self.store.pairing()
        if stored is not None:
            return stored
        pairing = await pair(self.client(), self.settings.name, __version__, self.shown)
        self.store.save_pairing(pairing)
        logger.info("Paired as connector %s", pairing.connector)
        return pairing

    def request_discovery(self) -> bool:
        """Start a discovery run unless one is running.

        Returns:
            True when a run started now.
        """
        if self.discovery_task is not None and not self.discovery_task.done():
            return False
        self.discovery_task = asyncio.create_task(self.run_discovery(), name="discovery")
        return True

    async def run_discovery(self) -> None:
        """Run discovery on the site LAN and report the candidates to the backend."""
        pairing = self.store.pairing()
        if pairing is None:
            return
        networks = self.networks()
        if not networks and not self.settings.subnets:
            logger.warning("Discovery found no site LAN interface; set SSS_CONNECTOR_INTERFACES")
        started = time.monotonic()
        candidates = await discover(networks, self.settings.subnets)
        self.last_discovery = {
            "interfaces": [network.name for network in networks],
            "candidates": len(candidates),
            "seconds": round(time.monotonic() - started, 1),
        }
        try:
            await self.client(pairing).report_discovery([candidate.report() for candidate in candidates])
        except BackendError as exc:
            logger.warning("Reporting discovery failed: %s", exc)

    async def heartbeat(self, pairing: Pairing) -> int:
        """Send one heartbeat and act on the answer.

        Args:
            pairing: The pairing.

        Returns:
            Seconds until the next heartbeat.
        """
        client = self.client(pairing)
        report = {
            "version": __version__,
            "address": self.settings.advertise_address or None,
            "api_port": self.settings.api_port,
            "rtsp_port": self.settings.rtsp_port,
            "uptime_seconds": round(time.monotonic() - self.started, 1),
            "cameras": await self.cameras.status(),
            "health": {"discovery": self.last_discovery},
        }
        ack = await client.heartbeat(report)
        if ack.get("config_version") and ack["config_version"] != self.config_version:
            config = await client.config()
            await self.cameras.reconcile(config)
            self.config_version = str(config.get("version") or ack["config_version"])
        if ack.get("discovery_requested"):
            self.request_discovery()
        return pairing.heartbeat_interval or self.settings.heartbeat_seconds

    async def serve_paired(self, pairing: Pairing) -> None:
        """Serve a pairing until the backend revokes it.

        Args:
            pairing: The pairing.
        """
        await self.go2rtc.start(
            go2rtc_config(
                self.settings.go2rtc_api, self.settings.rtsp_port, pairing.stream_username, pairing.stream_password
            )
        )
        await self.cameras.sync()
        if self.settings.discovery_interval:
            self.request_discovery()
        last_discovery = time.monotonic()
        while True:
            try:
                wait = await self.heartbeat(pairing)
            except Revoked:
                raise
            except BackendError as exc:
                logger.warning("Heartbeat failed: %s", exc)
                wait = self.settings.heartbeat_seconds
            interval = self.settings.discovery_interval
            if interval and time.monotonic() - last_discovery >= interval:
                last_discovery = time.monotonic()
                self.request_discovery()
            await asyncio.sleep(wait)

    async def forget(self) -> None:
        """Forget the pairing and every camera after the backend revoked the connector."""
        logger.warning("The backend revoked this connector; forgetting its cameras and pairing again")
        await self.go2rtc.stop()
        self.cameras.cameras = {}
        self.store.save_cameras({})
        self.store.save_pairing(None)
        self.config_version = ""

    async def run_backend(self) -> None:
        """Pair, then serve, and pair again whenever the connector is revoked."""
        while True:
            pairing = await self.paired()
            try:
                await self.serve_paired(pairing)
            except Revoked:
                await self.forget()

    async def run(self) -> None:
        """Run the agent API and the backend loop until cancelled."""
        server = uvicorn.Server(
            uvicorn.Config(
                create_app(self),
                host="0.0.0.0",
                port=self.settings.api_port,
                log_level="warning",
                access_log=False,
                lifespan="off",
            )
        )
        try:
            await asyncio.gather(server.serve(), self.run_backend())
        finally:
            await self.go2rtc.stop()
            if self.advertiser is not None:
                await self.advertiser.stop()

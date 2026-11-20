"""Application settings read from HC_ environment variables and the .env file."""

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import URL

APP_NAME = "home-cameras"
APP_VERSION = "0.1.0"


class Settings(BaseSettings):
    """Every setting of the backend.

    Attributes:
        lan_bind: Home network address the web app and the TV streams are published on.
        db_host: Postgres host.
        db_port: Postgres port.
        db_name: Postgres database.
        db_user: Postgres user.
        db_password: Postgres password.
        secret_key: Key that signs sessions and encrypts camera passwords.
        admin_username: User created on first start.
        admin_password: Password of that user on first start.
        session_hours: Lifetime of a session.
        go2rtc_url: go2rtc API address.
        transcode_hardware: go2rtc hardware option added to every transcode, empty for none.
        tv_rtsp_username: RTSP user of go2rtc for clients outside its container.
        tv_rtsp_password: RTSP password of go2rtc.
        discovery_subnet: Subnet scanned for cameras.
        monitor_interval_seconds: Interval of the camera status monitor.
        health_interval_seconds: Interval of the network health probes.
        health_retention_days: Days health samples are kept.
        events_dir: Folder of event snapshots and clips.
        events_retention_days: Days events are kept.
        replay_enabled: Whether SD card playback is offered.
        device_onvif_port: ONVIF port of bridged V380 cameras.
        device_username: Device login of bridged V380 cameras.
        device_password: Device password of bridged V380 cameras.
        analytics_url: Address of the analytics service's status endpoint.
        analytics_token: Shared token of the analytics service and the internal analytics endpoints.
    """

    model_config = SettingsConfigDict(env_prefix="HC_", env_file=".env", case_sensitive=False, extra="ignore")

    lan_bind: str = ""

    db_host: str = "127.0.0.1"
    db_port: int = 5432
    db_name: str = "home_cameras"
    db_user: str = "home_cameras"
    db_password: str = "home_cameras"

    secret_key: str = ""
    admin_username: str = "admin"
    admin_password: str = ""
    session_hours: int = 168

    go2rtc_url: str = "http://go2rtc:1984"
    transcode_hardware: str = ""

    tv_rtsp_username: str = "tv"
    tv_rtsp_password: str = ""

    discovery_subnet: str = "192.168.1.0/24"

    monitor_interval_seconds: int = 20

    health_interval_seconds: int = 10
    health_retention_days: int = 14

    events_dir: str = "/data/events"
    events_retention_days: int = 30

    replay_enabled: bool = False

    device_onvif_port: int = 8899
    device_username: str = Field(default="admin", validation_alias=AliasChoices("hc_device_username", "v380_username"))
    device_password: str = Field(default="", validation_alias=AliasChoices("hc_device_password", "v380_password"))

    analytics_url: str = "http://analytics:8080"
    analytics_token: str = ""

    @property
    def database_url(self) -> str:
        """str: Async SQLAlchemy URL of the database, with the password."""
        url = URL.create(
            "postgresql+asyncpg",
            username=self.db_user,
            password=self.db_password,
            host=self.db_host,
            port=self.db_port,
            database=self.db_name,
        )
        return url.render_as_string(hide_password=False)


settings = Settings()

from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import URL

APP_NAME = "home-cameras"
APP_VERSION = "0.1.0"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="HC_", env_file=".env", case_sensitive=False, extra="ignore")

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

    discovery_subnet: str = "192.168.1.0/24"

    monitor_interval_seconds: int = 20

    @property
    def database_url(self) -> str:
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

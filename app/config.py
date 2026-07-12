from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings, overridable via environment variables or a .env file."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "Python CRUD Cloud API"
    environment: str = "local"
    database_url: str = "sqlite:///./app.db"


@lru_cache
def get_settings() -> Settings:
    return Settings()

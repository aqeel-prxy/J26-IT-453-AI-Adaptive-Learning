import os
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "J26-IT-453 AI-Based Adaptive Learning Platform"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "dev_secret_key_change_in_production_j26_it_453")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days

    # Database Configuration
    DATABASE_URL: Optional[str] = os.getenv("DATABASE_URL")
    USE_SQLITE: bool = os.getenv("USE_SQLITE", "true").lower() in ("true", "1", "yes")

    # PostgreSQL Database (used when USE_SQLITE is False)
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "adaptive_learning_db")
    
    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        if self.USE_SQLITE:
            db_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "adaptive_learning.db"))
            # Normalize for sqlite URI on Windows
            normalized_path = db_path.replace("\\", "/")
            return f"sqlite:///{normalized_path}"
        return f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "*",
        "http://localhost",
        "http://localhost:8000",
        "http://localhost:3000",
        "http://127.0.0.1",
        "http://localhost:55275",
        "http://127.0.0.1:55275",
        "http://10.0.2.2"  # Android Emulator access to host
    ]

    model_config = SettingsConfigDict(
        case_sensitive=True,
        env_file=".env",
        extra="ignore"
    )


settings = Settings()

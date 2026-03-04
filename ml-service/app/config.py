"""
ML Service Configuration
────────────────────────
Central configuration for the ML prediction service.
"""
import os


class Settings:
    """Application settings loaded from environment variables."""

    # Server
    HOST: str = os.getenv("ML_HOST", "0.0.0.0")
    PORT: int = int(os.getenv("ML_PORT", "8000"))
    DEBUG: bool = os.getenv("ML_DEBUG", "false").lower() == "true"

    # Model Weights for Ensemble
    CHRONOS_WEIGHT: float = float(os.getenv("CHRONOS_WEIGHT", "0.40"))
    PROPHET_WEIGHT: float = float(os.getenv("PROPHET_WEIGHT", "0.30"))
    LR_WEIGHT: float = float(os.getenv("LR_WEIGHT", "0.20"))
    MA_WEIGHT: float = float(os.getenv("MA_WEIGHT", "0.10"))

    # Forecast Horizon
    DEFAULT_FORECAST_STEPS: int = int(os.getenv("FORECAST_STEPS", "7"))

    # Data Processing
    MIN_HISTORICAL_POINTS: int = int(os.getenv("MIN_HIST_POINTS", "7"))
    OUTLIER_Z_THRESHOLD: float = float(os.getenv("OUTLIER_Z_THRESHOLD", "3.0"))

    # Model Paths
    TRAINED_MODELS_DIR: str = os.getenv("TRAINED_MODELS_DIR", "data/trained_models")
    HISTORICAL_DATA_PATH: str = os.getenv("HISTORICAL_DATA_PATH", "data/historical_prices.csv")

    # Logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")

    @property
    def ensemble_weights(self) -> dict:
        return {
            "chronos": self.CHRONOS_WEIGHT,
            "prophet": self.PROPHET_WEIGHT,
            "lr": self.LR_WEIGHT,
            "ma": self.MA_WEIGHT,
        }


settings = Settings()
"""
Input Validators
────────────────
Validate and sanitize ML service input data.
"""
from typing import List, Optional
import logging

logger = logging.getLogger(__name__)


def validate_historical_data(
    prices: List[float], dates: List[str], min_points: int = 2
) -> bool:
    """
    Validate that historical data meets minimum requirements.
    
    Returns True if valid, False otherwise.
    """
    if not prices or not dates:
        logger.warning("Empty historical data provided")
        return False

    if len(prices) != len(dates):
        logger.warning(f"Price/date length mismatch: {len(prices)} vs {len(dates)}")
        return False

    if len(prices) < min_points:
        logger.warning(f"Insufficient data points: {len(prices)} < {min_points}")
        return False

    # Check for all-zero prices
    if all(p == 0 for p in prices):
        logger.warning("All prices are zero")
        return False

    return True


def validate_crop_id(crop_id: Optional[str]) -> bool:
    """Validate crop_id is a non-empty string."""
    if not crop_id or not isinstance(crop_id, str) or not crop_id.strip():
        return False
    return True


def validate_market_id(market_id: Optional[str]) -> bool:
    """Validate market_id is a non-empty string."""
    if not market_id or not isinstance(market_id, str) or not market_id.strip():
        return False
    return True


def sanitize_price(price) -> float:
    """Convert a price value to float safely."""
    try:
        val = float(price)
        return max(val, 0.0)  # No negative prices
    except (TypeError, ValueError):
        return 0.0


def validate_prediction_request(
    crop_id: str,
    market_id: str,
    prices: List[float],
    dates: List[str],
) -> tuple:
    """
    Full validation of a prediction request.
    
    Returns (is_valid: bool, error_message: str | None)
    """
    if not validate_crop_id(crop_id):
        return False, "Invalid or missing crop_id"

    if not validate_market_id(market_id):
        return False, "Invalid or missing market_id"

    if not validate_historical_data(prices, dates):
        return False, "Invalid or insufficient historical data"

    return True, None
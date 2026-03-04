"""
Feature Engineering
───────────────────
Extracts additional features from raw data to improve ML model performance.
Includes weather-based features, supply-demand proxies, and calendar features.
"""
import numpy as np
import logging
from typing import Dict, List, Optional
from datetime import datetime


class FeatureEngineer:
    """
    Generates derived features from historical prices and external data sources.
    """

    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def extract_calendar_features(self, dates: List[str]) -> List[Dict[str, float]]:
        """
        Extract calendar-based features from date strings.
        Returns a list of feature dicts, one per date.
        
        Features:
          - day_of_week: 0 (Mon) - 6 (Sun)
          - day_of_month: 1-31
          - month: 1-12
          - is_weekend: 0 or 1
          - week_of_year: 1-52
        """
        features = []
        for d in dates:
            try:
                dt = datetime.strptime(d, "%Y-%m-%d")
                features.append({
                    "day_of_week": float(dt.weekday()),
                    "day_of_month": float(dt.day),
                    "month": float(dt.month),
                    "is_weekend": 1.0 if dt.weekday() >= 5 else 0.0,
                    "week_of_year": float(dt.isocalendar()[1]),
                })
            except (ValueError, TypeError):
                features.append({
                    "day_of_week": 0.0,
                    "day_of_month": 1.0,
                    "month": 1.0,
                    "is_weekend": 0.0,
                    "week_of_year": 1.0,
                })
        return features

    def extract_weather_features(
        self, weather_forecast: Optional[dict]
    ) -> Dict[str, float]:
        """
        Convert weather forecast data into numeric features.

        Input weather_forecast dict:
          - temp: temperature in Celsius
          - rainfall: mm
          - humidity: percentage
          - conditions: string description

        Returns dict of normalized weather features.
        """
        if not weather_forecast:
            return {
                "temp_normalized": 0.5,
                "rainfall_normalized": 0.0,
                "humidity_normalized": 0.5,
                "is_rainy": 0.0,
                "is_extreme_heat": 0.0,
            }

        temp = weather_forecast.get("temp", 30)
        rainfall = weather_forecast.get("rainfall", 0)
        humidity = weather_forecast.get("humidity", 50)
        conditions = weather_forecast.get("conditions", "").lower()

        return {
            "temp_normalized": min(max((temp - 10) / 35, 0), 1),  # Normalize 10-45°C to 0-1
            "rainfall_normalized": min(rainfall / 100, 1),          # Cap at 100mm
            "humidity_normalized": humidity / 100,
            "is_rainy": 1.0 if any(w in conditions for w in ["rain", "storm", "drizzle"]) else 0.0,
            "is_extreme_heat": 1.0 if temp > 40 else 0.0,
        }

    def extract_price_features(self, prices: List[float]) -> Dict[str, float]:
        """
        Compute price-derived features from historical data.

        Features:
          - price_momentum: rate of change over last 7 days
          - price_volatility: coefficient of variation
          - price_acceleration: change in momentum
          - above_mean: whether latest price is above mean
        """
        if len(prices) < 2:
            return {
                "price_momentum": 0.0,
                "price_volatility": 0.0,
                "price_acceleration": 0.0,
                "above_mean": 0.0,
            }

        arr = np.array(prices, dtype=float)
        mean_price = float(np.mean(arr))
        std_price = float(np.std(arr))

        # Momentum: percentage change over recent window
        window = min(7, len(arr))
        recent = arr[-window:]
        momentum = ((recent[-1] - recent[0]) / recent[0]) * 100 if recent[0] != 0 else 0

        # Acceleration: change in momentum
        if len(arr) >= 14:
            prev_window = arr[-(2 * window):-window]
            prev_momentum = ((prev_window[-1] - prev_window[0]) / prev_window[0]) * 100 if prev_window[0] != 0 else 0
            acceleration = momentum - prev_momentum
        else:
            acceleration = 0.0

        # Coefficient of variation
        volatility = (std_price / mean_price) * 100 if mean_price > 0 else 0

        return {
            "price_momentum": round(momentum, 4),
            "price_volatility": round(volatility, 4),
            "price_acceleration": round(acceleration, 4),
            "above_mean": 1.0 if arr[-1] > mean_price else 0.0,
        }

    def extract_supply_demand_proxy(self, prices: List[float]) -> Dict[str, float]:
        """
        Estimate supply-demand proxy features from price patterns.
        
        Heuristics:
          - Rapid price increase → demand > supply
          - Rapid price decrease → supply > demand
          - Stable → equilibrium
        """
        if len(prices) < 7:
            return {"supply_demand_ratio": 1.0, "market_pressure": 0.0}

        recent = prices[-7:]
        earlier = prices[-14:-7] if len(prices) >= 14 else prices[:7]

        avg_recent = np.mean(recent)
        avg_earlier = np.mean(earlier)

        if avg_earlier > 0:
            ratio = avg_recent / avg_earlier
        else:
            ratio = 1.0

        # Market pressure: positive = demand pressure, negative = supply pressure
        pressure = (ratio - 1.0) * 100

        return {
            "supply_demand_ratio": round(float(ratio), 4),
            "market_pressure": round(float(pressure), 4),
        }

    def build_feature_vector(
        self,
        prices: List[float],
        dates: List[str],
        weather_forecast: Optional[dict] = None,
    ) -> dict:
        """
        Build the complete feature vector combining all feature sources.
        Returns a dict of all computed features.
        """
        features = {}
        features.update(self.extract_price_features(prices))
        features.update(self.extract_weather_features(weather_forecast))
        features.update(self.extract_supply_demand_proxy(prices))

        calendar = self.extract_calendar_features(dates)
        if calendar:
            # Use the latest date's calendar features
            features.update({f"cal_{k}": v for k, v in calendar[-1].items()})

        return features
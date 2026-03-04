"""
Weighted Ensemble Model
───────────────────────
Combines predictions from multiple models using configurable weights.
Used by PredictionService to produce the final forecast.
"""
import numpy as np
import logging
from typing import Dict, List, Optional


class WeightedEnsemble:
    """
    Combines multiple model predictions using weighted averaging.
    
    Default weights:
      - Chronos: 40% (best at variance capture)
      - Prophet: 30% (seasonality-aware)
      - Linear Regression: 20% (baseline trend)
      - Moving Average: 10% (smoothing)
    """

    DEFAULT_WEIGHTS = {
        "chronos": 0.40,
        "prophet": 0.30,
        "lr": 0.20,
        "ma": 0.10,
    }

    def __init__(self, weights: Optional[Dict[str, float]] = None):
        self.weights = weights or self.DEFAULT_WEIGHTS
        self.logger = logging.getLogger(__name__)

    def combine(
        self,
        predictions: Dict[str, List[dict]],
        steps: int = 7,
        fallback_price: float = 0.0,
    ) -> List[dict]:
        """
        Combine predictions from multiple models.

        Args:
            predictions: Dict mapping model_name -> list of {mean, low, high}
            steps: Number of forecast steps
            fallback_price: Price to use if all models fail

        Returns:
            List of {mean, low, high} dicts
        """
        ensemble = []
        for i in range(steps):
            mean_val = 0.0
            low_val = 0.0
            high_val = 0.0
            total_weight = 0.0

            for model_name, weight in self.weights.items():
                if model_name in predictions and len(predictions[model_name]) == steps:
                    mean_val += predictions[model_name][i]["mean"] * weight
                    low_val += predictions[model_name][i]["low"] * weight
                    high_val += predictions[model_name][i]["high"] * weight
                    total_weight += weight

            if total_weight > 0:
                ensemble.append({
                    "mean": mean_val / total_weight,
                    "low": low_val / total_weight,
                    "high": high_val / total_weight,
                })
            else:
                # All models failed — use fallback
                ensemble.append({
                    "mean": fallback_price,
                    "low": fallback_price * 0.9,
                    "high": fallback_price * 1.1,
                })

        return ensemble

    def compute_trend(
        self, ensemble: List[dict], current_price: float
    ) -> tuple:
        """
        Compute trend direction and recommendation from ensemble output.

        Returns:
            (trend, recommendation) — e.g. ("UP", "WAIT")
        """
        if not ensemble:
            return "STABLE", "SELL"

        final_price = ensemble[-1]["mean"]
        pct_change = ((final_price - current_price) / current_price) * 100 if current_price else 0

        if pct_change > 2:
            trend = "UP"
        elif pct_change < -2:
            trend = "DOWN"
        else:
            trend = "STABLE"

        recommendation = "WAIT" if trend == "UP" else "SELL"
        return trend, recommendation

    def compute_confidence(self, ensemble: List[dict]) -> float:
        """
        Compute ensemble confidence based on spread between upper and lower bounds.
        Tighter bounds → higher confidence.
        """
        if not ensemble:
            return 0.0

        spreads = []
        for p in ensemble:
            if p["mean"] > 0:
                spreads.append((p["high"] - p["low"]) / p["mean"])

        if not spreads:
            return 0.0

        avg_spread = float(np.mean(spreads))
        return round(max(0.1, 1.0 - avg_spread), 4)
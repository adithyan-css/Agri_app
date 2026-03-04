"""
Data Processor
──────────────
Handles cleaning, outlier removal, and seasonal decomposition
of raw historical price data before it enters the ML pipeline.
"""
import numpy as np
import pandas as pd
import logging
from typing import List, Tuple, Optional


class DataProcessor:
    """
    Cleans and processes raw price time-series for ML model consumption.
    """

    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def clean_prices(self, prices: List[float], dates: List[str]) -> Tuple[List[float], List[str]]:
        """
        Remove NaN/null values and zero prices from the series.
        Returns cleaned (prices, dates) tuple.
        """
        if not prices or not dates:
            return prices, dates

        clean_prices = []
        clean_dates = []
        for p, d in zip(prices, dates):
            if p is not None and not np.isnan(p) and p > 0:
                clean_prices.append(p)
                clean_dates.append(d)
            else:
                self.logger.debug(f"Removed invalid price at {d}: {p}")

        return clean_prices, clean_dates

    def remove_outliers(
        self, prices: List[float], dates: List[str], z_threshold: float = 3.0
    ) -> Tuple[List[float], List[str]]:
        """
        Remove statistical outliers using Z-score method.
        Points with |z| > threshold are replaced with the median.
        """
        if len(prices) < 3:
            return prices, dates

        arr = np.array(prices, dtype=float)
        mean = np.mean(arr)
        std = np.std(arr)

        if std == 0:
            return prices, dates

        z_scores = np.abs((arr - mean) / std)
        median = np.median(arr)

        cleaned = []
        for i, (p, z) in enumerate(zip(prices, z_scores)):
            if z > z_threshold:
                self.logger.info(f"Outlier at {dates[i]}: {p} (z={z:.2f}), replaced with median {median}")
                cleaned.append(float(median))
            else:
                cleaned.append(p)

        return cleaned, dates

    def interpolate_missing_dates(
        self, prices: List[float], dates: List[str]
    ) -> Tuple[List[float], List[str]]:
        """
        Fill in missing calendar dates with linearly interpolated prices.
        Ensures a continuous daily time series.
        """
        if len(prices) < 2:
            return prices, dates

        try:
            df = pd.DataFrame({"date": pd.to_datetime(dates), "price": prices})
            df = df.set_index("date").sort_index()

            # Reindex to fill missing days
            full_range = pd.date_range(start=df.index.min(), end=df.index.max(), freq="D")
            df = df.reindex(full_range)
            df["price"] = df["price"].interpolate(method="linear")
            df = df.dropna()

            return df["price"].tolist(), [d.strftime("%Y-%m-%d") for d in df.index]
        except Exception as e:
            self.logger.error(f"Interpolation failed: {e}")
            return prices, dates

    def compute_rolling_stats(
        self, prices: List[float], window: int = 7
    ) -> dict:
        """
        Compute rolling statistics for feature engineering.
        Returns dict with rolling_mean, rolling_std, rolling_min, rolling_max.
        """
        arr = np.array(prices, dtype=float)
        if len(arr) < window:
            return {
                "rolling_mean": float(np.mean(arr)) if len(arr) > 0 else 0.0,
                "rolling_std": float(np.std(arr)) if len(arr) > 0 else 0.0,
                "rolling_min": float(np.min(arr)) if len(arr) > 0 else 0.0,
                "rolling_max": float(np.max(arr)) if len(arr) > 0 else 0.0,
            }

        return {
            "rolling_mean": float(np.mean(arr[-window:])),
            "rolling_std": float(np.std(arr[-window:])),
            "rolling_min": float(np.min(arr[-window:])),
            "rolling_max": float(np.max(arr[-window:])),
        }

    def process(
        self, prices: List[float], dates: List[str], remove_outlier: bool = True
    ) -> Tuple[List[float], List[str]]:
        """
        Full processing pipeline: clean → interpolate → outlier removal.
        """
        prices, dates = self.clean_prices(prices, dates)
        prices, dates = self.interpolate_missing_dates(prices, dates)
        if remove_outlier:
            prices, dates = self.remove_outliers(prices, dates)
        return prices, dates
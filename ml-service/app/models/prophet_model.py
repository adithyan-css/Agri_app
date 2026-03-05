import pandas as pd
try:
    from prophet import Prophet
except ImportError:
    Prophet = None
import logging

class ProphetForecaster:
    """
    Facebook Prophet model for robust time-series containing weekly/yearly seasonality.
    Requires historical dataframe with 'ds' and 'y' columns.
    """
    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def predict(self, historical_prices: list, dates: list, steps: int = 7) -> list:
        if Prophet is None:
            self.logger.warning("Prophet not installed, falling back to flatlines.")
            val = historical_prices[-1] if historical_prices else 0
            return [{"mean": val, "low": val*0.9, "high": val*1.1} for _ in range(steps)]

        if len(historical_prices) < 14:
            self.logger.warning("Prophet requires more historical data points, falling back to flatlines.")
            val = historical_prices[-1] if historical_prices else 0
            return [{"mean": val, "low": val*0.9, "high": val*1.1} for _ in range(steps)]

        df = pd.DataFrame({
            'ds': pd.to_datetime(dates),
            'y': historical_prices
        })
        
        # Initialize and fit the model
        model = Prophet(daily_seasonality=False, yearly_seasonality=False, weekly_seasonality=True)
        model.fit(df)
        
        # Make future dataframe
        future = model.make_future_dataframe(periods=steps)
        forecast = model.predict(future)
        
        # Extract the last `steps` rows
        future_forecast = forecast.tail(steps)
        
        predictions = []
        for _, row in future_forecast.iterrows():
            predictions.append({
                "mean": float(row['yhat']),
                "low": float(row['yhat_lower']),
                "high": float(row['yhat_upper'])
            })
            
        return predictions

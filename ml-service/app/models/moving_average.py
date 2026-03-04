import numpy as np

class MovingAverageModel:
    """
    Simple Moving Average forecaster for short-term trends.
    """
    def __init__(self, window_size: int = 7):
        self.window_size = window_size
        
    def predict(self, historical_data: list, steps: int = 7) -> list:
        if len(historical_data) < self.window_size:
            # Fallback to simple average if not enough data
            avg = sum(historical_data) / max(len(historical_data), 1)
            mean_val = avg if avg > 0 else 0
            return [{"mean": mean_val, "low": mean_val * 0.9, "high": mean_val * 1.1} for _ in range(steps)]
            
        predictions = []
        current_data = list(historical_data)
        
        for _ in range(steps):
            window = current_data[-self.window_size:]
            next_val = sum(window) / self.window_size
            current_data.append(next_val)
            
            # Simple standard deviation bounds
            std_dev = np.std(window) if len(window) > 1 else next_val * 0.05
            
            predictions.append({
                "mean": next_val,
                "low": next_val - (std_dev * 1.5),
                "high": next_val + (std_dev * 1.5)
            })
            
        return predictions

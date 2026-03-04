import numpy as np
from sklearn.linear_model import LinearRegression as SklearnLR

class LinearRegressionModel:
    """
    Scikit-Learn Linear Regression model for detecting core baseline trends.
    """
    def __init__(self):
        self.model = SklearnLR()
        
    def predict(self, historical_data: list, steps: int = 7) -> list:
        if len(historical_data) < 2:
            val = historical_data[0] if historical_data else 0
            return [{"mean": val, "low": val*0.9, "high": val*1.1} for _ in range(steps)]
            
        # Prepare X (days) and y (prices)
        X = np.arange(len(historical_data)).reshape(-1, 1)
        y = np.array(historical_data)
        
        self.model.fit(X, y)
        
        # Predict future steps
        future_X = np.arange(len(historical_data), len(historical_data) + steps).reshape(-1, 1)
        future_y = self.model.predict(future_X)
        
        # Calculate error margin bounds based on historical residuals
        historical_pred = self.model.predict(X)
        mse = np.mean((y - historical_pred) ** 2)
        rmse = np.sqrt(mse)
        
        predictions = []
        for val in future_y:
            predictions.append({
                "mean": float(val),
                "low": float(val - (rmse * 1.96)), # 95% confidence interval roughly
                "high": float(val + (rmse * 1.96))
            })
            
        return predictions

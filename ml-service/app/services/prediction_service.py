from app.schemas.prediction_request import PredictionRequest
from app.schemas.prediction_response import PredictionResponse, PricePoint
from app.models.chronos_forecaster import ChronosForecaster
from app.models.moving_average import MovingAverageModel
from app.models.linear_regression import LinearRegressionModel
from app.models.prophet_model import ProphetForecaster
from app.config import settings
import datetime
import numpy as np
import logging

class PredictionService:
    def __init__(self):
        self.chronos = ChronosForecaster()
        self.ma = MovingAverageModel()
        self.lr = LinearRegressionModel()
        self.prophet = ProphetForecaster()
        self.logger = logging.getLogger(__name__)

    def predict(self, request: PredictionRequest) -> PredictionResponse:
        """
        Routes the prediction request to a weighted ensemble of multiple models.
        """
        historical_prices = [item.price for item in request.historical_data]
        historical_dates = [item.date for item in request.historical_data]

        if not historical_prices or not historical_dates:
            self.logger.warning("No historical data provided; returning fallback prediction.")
            today = datetime.datetime.utcnow()
            fallback_price = 30.0
            predictions = [
                PricePoint(
                    date=(today + datetime.timedelta(days=i+1)).strftime("%Y-%m-%d"),
                    predicted_price=fallback_price,
                    lower_bound=fallback_price * 0.9,
                    upper_bound=fallback_price * 1.1
                )
                for i in range(7)
            ]
            return PredictionResponse(
                crop_id=request.crop_id,
                market_id=request.market_id,
                predictions=predictions,
                confidence_score=0.1,
                trend_direction="STABLE",
                recommendation="SELL"
            )
        
        steps = 7
        
        # Gather predictions from different models
        preds = {}
        
        try:
            preds['chronos'] = self.chronos.predict(historical_prices, steps)
        except Exception as e:
            self.logger.error(f"Chronos failed: {e}")
            
        try:
            preds['ma'] = self.ma.predict(historical_prices, steps)
        except Exception as e:
            self.logger.error(f"MA failed: {e}")
            
        try:
            preds['lr'] = self.lr.predict(historical_prices, steps)
        except Exception as e:
            self.logger.error(f"LR failed: {e}")
            
        try:
            preds['prophet'] = self.prophet.predict(historical_prices, historical_dates, steps)
        except Exception as e:
            self.logger.error(f"Prophet failed: {e}")

        # Weighted Ensemble Generation
        # Assuming Chronos/Prophet are better at capturing variance
        weights = {
            "chronos": settings.CHRONOS_WEIGHT,
            "prophet": settings.PROPHET_WEIGHT,
            "lr": settings.LR_WEIGHT,
            "ma": settings.MA_WEIGHT,
        }
        
        ensemble = []
        for i in range(steps):
            mean_val = 0
            low_val = 0
            high_val = 0
            total_weight = 0
            
            for model_name, w in weights.items():
                if model_name in preds and len(preds[model_name]) == steps:
                    mean_val += preds[model_name][i]['mean'] * w
                    low_val += preds[model_name][i]['low'] * w
                    high_val += preds[model_name][i]['high'] * w
                    total_weight += w
                    
            if total_weight > 0:
                ensemble.append({
                    "mean": mean_val / total_weight,
                    "low": low_val / total_weight,
                    "high": high_val / total_weight
                })
            else:
                ensemble.append({"mean": historical_prices[-1], "low": historical_prices[-1]*0.9, "high": historical_prices[-1]*1.1})
                
        # Format response dates
        try:
            last_date = datetime.datetime.strptime(historical_dates[-1].split('T')[0], "%Y-%m-%d")
        except (ValueError, IndexError):
            last_date = datetime.datetime.utcnow()
        
        predictions = []
        for i, pred in enumerate(ensemble):
            next_date = (last_date + datetime.timedelta(days=i+1)).strftime("%Y-%m-%d")
            predictions.append(PricePoint(
                date=next_date,
                predicted_price=round(pred["mean"], 2),
                lower_bound=round(pred["low"], 2),
                upper_bound=round(pred["high"], 2)
            ))
            
        # Calculate trend and recommendation
        current_price = historical_prices[-1] if historical_prices else 0
        final_price = predictions[-1].predicted_price
        
        percent_change = ((final_price - current_price) / current_price) * 100 if current_price else 0
        
        trend = "STABLE"
        if percent_change > 2:
            trend = "UP"
        elif percent_change < -2:
            trend = "DOWN"
            
        recommendation = "WAIT" if trend == "UP" else "SELL"
        
        # Calculate ensemble confidence based on dispersion between high and low bounds
        spreads = []
        for p in predictions:
            if p.predicted_price > 0:
                spreads.append((p.upper_bound - p.lower_bound) / p.predicted_price)
        avg_spread = np.mean(spreads) if spreads else 1.0
        confidence_score = round(max(0.1, 1.0 - avg_spread), 4)

        return PredictionResponse(
            crop_id=request.crop_id,
            market_id=request.market_id,
            predictions=predictions,
            confidence_score=confidence_score,
            trend_direction=trend,
            recommendation=recommendation
        )

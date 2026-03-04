from pydantic import BaseModel
from typing import List

class PricePoint(BaseModel):
    date: str
    predicted_price: float
    lower_bound: float
    upper_bound: float

class PredictionResponse(BaseModel):
    crop_id: str
    market_id: str
    predictions: List[PricePoint]
    confidence_score: float
    trend_direction: str # "UP", "DOWN", "STABLE"
    recommendation: str # "SELL", "WAIT"

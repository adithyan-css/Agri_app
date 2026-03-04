from pydantic import BaseModel
from typing import List, Optional

class HistoricalPrice(BaseModel):
    date: str
    price: float

class PredictionRequest(BaseModel):
    crop_id: str
    market_id: str
    historical_data: List[HistoricalPrice]
    weather_forecast: Optional[dict] = None
    use_model: str = "chronos" # options: "chronos", "ma", "prophet"

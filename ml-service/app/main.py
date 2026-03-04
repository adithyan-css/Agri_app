from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.schemas.prediction_request import PredictionRequest
from app.schemas.prediction_response import PredictionResponse
from app.services.prediction_service import PredictionService

app = FastAPI(title="AgriPrice AI - ML Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

prediction_service = PredictionService()

@app.get("/")
def read_root():
    return {"message": "AgriPrice AI ML Service is running"}

@app.post("/predict", response_model=PredictionResponse)
def predict_price(request: PredictionRequest):
    """
    Predict 7-day crop prices using selected model
    """
    return prediction_service.predict(request)

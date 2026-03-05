from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.schemas.prediction_request import PredictionRequest
from app.schemas.prediction_response import PredictionResponse
from app.services.prediction_service import PredictionService

app = FastAPI(title="AgriPrice AI - ML Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"detail": "Internal prediction error"})

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

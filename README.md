<p align="center">
  <img src="mobile/assets/icons/app_icon.png" alt="AgriPrice AI Logo" width="120" height="120">
</p>

<h1 align="center">AgriPrice AI</h1>

<p align="center">
  <strong>AI-Powered Agriculture Market Intelligence Platform</strong>
</p>

<p align="center">
  Helping farmers maximize profits through intelligent price prediction, market comparison, and sell-or-wait recommendations.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs" alt="NestJS">
  <img src="https://img.shields.io/badge/FastAPI-0.104-009688?logo=fastapi" alt="FastAPI">
  <img src="https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Backend Architecture](#backend-architecture)
- [ML Service Architecture](#ml-service-architecture)
- [Mobile App Architecture](#mobile-app-architecture)
- [API Endpoints](#api-endpoints)
- [ML Model Pipeline](#ml-model-pipeline)
- [Installation Guide](#installation-guide)
- [Running with Docker](#running-with-docker)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Future Improvements](#future-improvements)
- [Contributing](#contributing)
- [License](#license)

---

## Problem Statement

Indian farmers lose **15–25% of potential income** due to information asymmetry in agricultural markets:

- **No real-time price visibility** — Farmers sell at local mandis without knowing better prices exist nearby.
- **No demand forecasting** — Decisions to sell now or wait are based on guesswork, not data.
- **Hidden transport costs** — Traveling to a higher-priced market may not be profitable after factoring fuel and logistics.
- **Weather blind spots** — Rainfall, temperature shifts, and seasonal patterns directly affect prices, but farmers lack tools to factor this in.

## Solution Overview

**AgriPrice AI** is a full-stack mobile platform that solves these problems through:

1. **Real-time Mandi Price Tracking** — Live prices from 2,000+ markets across India, with offline caching.
2. **AI Price Prediction** — 7-day price forecasts using a weighted ensemble of 4 ML models.
3. **Sell or Wait Recommendation** — An AI engine that compares current vs. predicted prices and tells farmers whether to sell now or hold.
4. **Nearby Market Discovery** — PostGIS-powered spatial queries to find the best markets within a given radius.
5. **Transport Profit Calculator** — Calculates net profit after transport costs, so farmers know the real value of traveling to a distant market.
6. **Price Alerts** — Push notifications when a crop crosses a target price at a specific market.
7. **Weather Impact Analysis** — Integrates OpenWeatherMap data into prediction models for weather-aware forecasts.

---

## Key Features

| Feature | Description |
|---|---|
| **Mandi Price Tracking** | Real-time prices across 2,000+ markets with offline caching |
| **AI Price Prediction** | 7-day forecasts using Chronos, Prophet, Linear Regression & Moving Average ensemble |
| **Sell or Wait AI** | Compares current price vs. predicted trend to recommend optimal sell timing |
| **Nearby Markets** | GPS + PostGIS spatial queries to discover markets within a custom radius |
| **Transport Profit** | Net profit calculation factoring distance, fuel, truck capacity, and per-km rates |
| **Price Alerts** | Configurable alerts (above/below threshold) with push notifications |
| **Weather Impact** | Weather-aware predictions integrating temperature, rainfall, and humidity |
| **Truck Booking** | Browse available trucks, compare rates, and book transport |
| **Multilingual** | Full English and Tamil (தமிழ்) localization |
| **Voice Input** | Speech-to-text for hands-free market search |
| **Offline Mode** | Cached mandi prices available without internet |
| **Firebase Auth** | Google Sign-In and Email/Password authentication |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          MOBILE APP (Flutter)                           │
│  ┌───────────┐  ┌──────────┐  ┌────────────┐  ┌─────────────────────┐  │
│  │ Riverpod  │  │ GoRouter │  │ Firebase   │  │   Dio HTTP Client   │  │
│  │ Providers │  │ Nav      │  │ Auth       │  │   + Interceptors    │  │
│  └─────┬─────┘  └────┬─────┘  └─────┬──────┘  └──────────┬──────────┘  │
│        │              │              │                     │             │
│        └──────────────┴──────────────┴─────────────────────┘             │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │  HTTP REST (JSON)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        BACKEND (NestJS + TypeORM)                       │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌────────┐  ┌───────────┐ │
│  │   Auth   │  │  Crops   │  │  Markets  │  │ Alerts │  │ Transport │ │
│  │  Module  │  │  Module  │  │  Module   │  │ Module │  │  Module   │ │
│  └──────────┘  └──────────┘  └───────────┘  └────────┘  └───────────┘ │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌────────────────────────┐ │
│  │Predictions│ │ Weather  │  │Recommend- │  │ Swagger API Docs      │ │
│  │  Module  │  │  Module  │  │  ations   │  │ at /api/docs          │ │
│  └────┬─────┘  └──────────┘  └───────────┘  └────────────────────────┘ │
│       │                                                                 │
└───────┼─────────────────────────┬───────────────────────────────────────┘
        │  HTTP POST /predict     │  TypeORM
        ▼                         ▼
┌───────────────────┐    ┌────────────────────────────────┐
│  ML SERVICE       │    │  PostgreSQL 15 + PostGIS 3.3   │
│  (FastAPI/Python) │    │                                │
│                   │    │  Tables:                       │
│  ┌─────────────┐  │    │  ├── users                     │
│  │  Chronos    │  │    │  ├── crops                     │
│  │  (40%)      │  │    │  ├── markets (geometry/Point)  │
│  ├─────────────┤  │    │  ├── crop_prices               │
│  │  Prophet    │  │    │  ├── predictions                │
│  │  (30%)      │  │    │  ├── alerts                    │
│  ├─────────────┤  │    │  ├── trucks                    │
│  │  Linear Reg │  │    │  └── bookings                  │
│  │  (20%)      │  │    │                                │
│  ├─────────────┤  │    └────────────────────────────────┘
│  │  Moving Avg │  │               │
│  │  (10%)      │  │    ┌──────────┴─────────┐
│  └─────────────┘  │    │   Redis 7           │
│                   │    │   (Cache/Sessions)   │
│  Ensemble Output  │    └────────────────────┘
└───────────────────┘
```

### Data Flow — AI Prediction

```
User taps "Predict" on a crop
        │
        ▼
Flutter Provider ─────► GET /predictions/:cropId/markets/:marketId/forecast
        │
        ▼
NestJS PredictionsService
  ├─ Check DB cache (predictions generated today?) ──► YES → Return cached + compute trend
  └─ NO → Fetch 90-day historical prices
         Fetch market weather (OpenWeatherMap)
         POST to ML Service /predict
              │
              ▼
         FastAPI PredictionService
           ├─ Chronos forecast (40% weight)
           ├─ Prophet forecast (30% weight)
           ├─ Linear Regression (20% weight)
           └─ Moving Average (10% weight)
           ──► Weighted Ensemble → 7-day predictions
              │
              ▼
         Store in DB → Return to Flutter
              │
              ▼
         Chart + Forecast Table + Confidence Score
```

### Data Flow — Sell or Wait Recommendation

```
User taps "AI Analysis" on prediction screen
        │
        ▼
Flutter Provider ─────► GET /predictions/:cropId?marketId=
        │
        ▼
NestJS PredictionsService.getSellOrWaitRecommendation()
  ├─ Fetch latest market price for crop
  ├─ Fetch AI forecast (cache or ML service)
  ├─ Compare: max predicted price vs current price
  │    ├─ max_predicted > current → WAIT (prices rising)
  │    └─ otherwise              → SELL (prices flat/dropping)
  ├─ Compute trend: UP / DOWN / STABLE (±2% threshold)
  ├─ Calculate expected profit per kg
  └─ Generate human-readable reason
        │
        ▼
  Recommendation Card + Price Trend Chart + Market Factors
```

---

## Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Mobile** | Flutter (Dart) | Cross-platform mobile UI |
| **State Management** | Riverpod | Reactive state with providers |
| **Routing** | GoRouter | Declarative, type-safe navigation |
| **HTTP Client** | Dio | REST API calls with interceptors |
| **Auth** | Firebase Authentication | Google Sign-In + Email/Password |
| **Backend** | NestJS (TypeScript) | RESTful API server |
| **ORM** | TypeORM | Database abstraction |
| **Database** | PostgreSQL 15 + PostGIS 3.3 | Relational DB with spatial queries |
| **Cache** | Redis 7 | Session cache and rate limiting |
| **ML Service** | FastAPI (Python) | AI prediction microservice |
| **ML Models** | Chronos, Prophet, Scikit-learn | Time-series forecasting |
| **Charts** | fl_chart | Price trend visualization |
| **Localization** | flutter_localizations + intl | English & Tamil support |
| **Voice** | speech_to_text | Voice-based search |
| **Notifications** | Firebase Cloud Messaging | Push notifications for alerts |
| **API Docs** | Swagger / OpenAPI | Auto-generated interactive docs |
| **Deployment** | Docker, Kubernetes, Nginx | Container orchestration |

---

## Project Structure

```
agri_app/
│
├── mobile/                          # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── config/                  # Routes, theme, app config
│   │   ├── core/                    # Auth, network, storage, utils
│   │   ├── data/                    # Models, repositories, API clients
│   │   │   ├── data_sources/
│   │   │   │   ├── remote/          # 9 API clients (Dio-based)
│   │   │   │   └── local/           # Offline cache manager
│   │   │   ├── models/              # 11 data models
│   │   │   └── repositories/        # 9 repository classes
│   │   ├── domain/                  # Use cases (business logic)
│   │   ├── presentation/            # UI Layer
│   │   │   ├── screens/             # 20+ screens
│   │   │   ├── providers/           # 10 Riverpod providers
│   │   │   └── widgets/             # Reusable components & charts
│   │   └── l10n/                    # Localization (EN, TA)
│   ├── assets/                      # Fonts, icons, images
│   ├── android/                     # Android platform config
│   ├── ios/                         # iOS platform config
│   └── pubspec.yaml                 # Flutter dependencies
│
├── backend/                         # NestJS API Server
│   ├── src/
│   │   ├── main.ts                  # Server entry point
│   │   ├── app.module.ts            # Root module
│   │   ├── config/                  # Database, JWT, Redis, Swagger config
│   │   ├── common/                  # Guards, pipes, filters, interceptors
│   │   └── modules/                 # Feature modules
│   │       ├── auth/                # Firebase auth sync
│   │       ├── crops/               # Crop catalog & pricing
│   │       ├── markets/             # Market geospatial queries
│   │       ├── predictions/         # AI forecast & recommendations
│   │       ├── alerts/              # Price alert management
│   │       ├── weather/             # OpenWeatherMap integration
│   │       ├── transport/           # Truck booking & logistics
│   │       ├── recommendations/     # Profit calculation engine
│   │       ├── notifications/       # FCM push notifications
│   │       ├── users/               # User management
│   │       └── seed/                # Database seeding
│   ├── database/                    # Schema, migrations, seeds
│   ├── test/                        # E2E tests
│   └── package.json                 # Node.js dependencies
│
├── ml-service/                      # Python ML Microservice
│   ├── app/
│   │   ├── main.py                  # FastAPI entry point
│   │   ├── config.py                # ML configuration
│   │   ├── services/
│   │   │   └── prediction_service.py  # Ensemble prediction engine
│   │   ├── models/                  # ML model implementations
│   │   │   ├── chronos_forecaster.py
│   │   │   ├── prophet_model.py
│   │   │   ├── linear_regression.py
│   │   │   ├── moving_average.py
│   │   │   └── ensemble.py
│   │   ├── schemas/                 # Pydantic request/response models
│   │   └── utils/                   # Data preprocessing utilities
│   ├── data/                        # Historical prices & trained models
│   ├── notebooks/                   # Jupyter training notebooks
│   ├── tests/                       # Unit tests
│   └── requirements.txt             # Python dependencies
│
├── deployment/                      # Deployment Configuration
│   ├── docker/                      # Dockerfiles per service
│   ├── kubernetes/                  # K8s manifests
│   │   ├── backend-deployment.yaml
│   │   ├── ml-service-deployment.yaml
│   │   ├── postgres-deployment.yaml
│   │   ├── redis-deployment.yaml
│   │   ├── ingress.yaml
│   │   └── secrets.yaml
│   ├── scripts/                     # DB backup, seed, setup scripts
│   ├── docker-compose.yml           # Dev environment
│   └── docker-compose.prod.yml      # Production environment
│
└── docker-compose.yml               # Quick-start compose (DB + Redis + Services)
```

---

## Backend Architecture

The backend follows a **modular NestJS architecture** with 12 feature modules:

```
┌──────────────────────────────────────────────────────┐
│                  NestJS Application                    │
│                                                       │
│  Global Prefix: /api/v1                               │
│  Auth Guard: Firebase Token Verification              │
│  Validation: class-validator (whitelist mode)         │
│  API Docs: Swagger at /api/docs                      │
│                                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │              Feature Modules                    │  │
│  │                                                 │  │
│  │  auth       crops      markets    alerts        │  │
│  │  users      weather    transport  predictions   │  │
│  │  recommend. notif.     seed       ml-service    │  │
│  └─────────────────────────────────────────────────┘  │
│                                                       │
│  ┌──────────────┐  ┌───────────┐  ┌───────────┐      │
│  │   TypeORM    │  │   Redis   │  │  Firebase  │      │
│  │  PostgreSQL  │  │   Cache   │  │  Admin SDK │      │
│  └──────────────┘  └───────────┘  └───────────┘      │
└──────────────────────────────────────────────────────┘
```

### Key Backend Patterns

- **Entity-based architecture** — Each module owns its entities, DTOs, controller, and service.
- **Firebase Auth Guard** — All endpoints verify Firebase ID tokens via the Admin SDK.
- **PostGIS spatial queries** — Market discovery uses `ST_DWithin`, `ST_Distance`, `ST_X/Y` for geospatial radius search.
- **Prediction caching** — AI forecasts are cached in the database for 24 hours to minimize ML service calls.
- **Swagger auto-docs** — Full interactive API documentation at `/api/docs`.

---

## ML Service Architecture

The ML service is a standalone **FastAPI microservice** that accepts historical price data and weather context, returning 7-day price forecasts.

### Ensemble Model

```
Historical Prices (90 days) + Weather Data
                │
    ┌───────────┼───────────────────────────┐
    ▼           ▼              ▼             ▼
┌────────┐ ┌────────┐  ┌──────────┐  ┌──────────┐
│Chronos │ │Prophet │  │  Linear  │  │  Moving  │
│  40%   │ │  30%   │  │ Regress. │  │ Average  │
│        │ │        │  │   20%    │  │   10%    │
└───┬────┘ └───┬────┘  └────┬─────┘  └────┬─────┘
    │          │             │             │
    └──────────┴─────────────┴─────────────┘
                      │
                      ▼
              Weighted Ensemble
              ───────────────
              7-Day Forecast
              ├── predicted_price
              ├── lower_bound
              ├── upper_bound
              ├── confidence_score
              ├── trend_direction (UP / DOWN / STABLE)
              └── recommendation  (SELL / WAIT)
```

### Prediction Request

```json
{
  "crop_id": "uuid",
  "market_id": "uuid",
  "use_model": "chronos",
  "historical_data": [
    { "date": "2026-03-01", "price": 25.50 },
    { "date": "2026-03-02", "price": 26.00 }
  ],
  "weather_forecast": {
    "temp": 30,
    "rainfall": 0,
    "humidity": 65,
    "conditions": "Clear"
  }
}
```

### Prediction Response

```json
{
  "crop_id": "uuid",
  "market_id": "uuid",
  "predictions": [
    {
      "date": "2026-03-06",
      "predicted_price": 26.82,
      "lower_bound": 25.17,
      "upper_bound": 28.48
    }
  ],
  "confidence_score": 0.877,
  "trend_direction": "UP",
  "recommendation": "WAIT"
}
```

---

## Mobile App Architecture

The Flutter app follows **Clean Architecture** with three distinct layers:

```
┌─────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                   │
│                                                      │
│  Screens (20+)    Providers (Riverpod)    Widgets   │
│  ├── Home         ├── auth_provider        Charts   │
│  ├── Markets      ├── crop_provider        Cards    │
│  ├── Predictions  ├── market_provider      Forms    │
│  ├── AI Analysis  ├── prediction_provider          │
│  ├── Alerts       ├── location_provider            │
│  ├── Transport    ├── weather_provider             │
│  ├── Weather      └── ...                          │
│  └── Profile                                        │
├─────────────────────────────────────────────────────┤
│                   DOMAIN LAYER                       │
│                                                      │
│  Use Cases                                          │
│  ├── get_crop_prices                                │
│  ├── get_nearby_markets                             │
│  ├── get_predictions                                │
│  └── calculate_transport_profit                     │
├─────────────────────────────────────────────────────┤
│                    DATA LAYER                        │
│                                                      │
│  Remote API Clients (9)    Local Storage             │
│  ├── crop_api              ├── cache_manager         │
│  ├── market_api            └── local_data_service    │
│  ├── prediction_api                                  │
│  ├── weather_api           Models (11)               │
│  ├── alert_api             ├── crop_price_model      │
│  ├── auth_api              ├── market_model          │
│  ├── transport_api         ├── prediction_model      │
│  └── recommendation_api   └── ...                    │
│                                                      │
│  Repositories (9)                                    │
│  ├── crop_repository      ├── alert_repository      │
│  ├── market_repository    ├── transport_repository   │
│  └── prediction_repository                           │
└─────────────────────────────────────────────────────┘
```

### App Screens

| Route | Screen | Description |
|---|---|---|
| `/` | Home | Dashboard with price overview and quick actions |
| `/markets` | Markets | Browse all markets with live prices |
| `/nearby-markets` | Nearby Markets | GPS-based market discovery |
| `/market-detail/:id` | Market Detail | Market info, crops, and prices |
| `/predictions` | Predictions | Select crop + market for forecast |
| `/predictions/:cropId/:marketId` | Prediction Detail | 7-day chart, ensemble results, confidence |
| `/ai-analysis/:cropId/:marketId` | AI Recommendation | Sell/Wait analysis with reasoning |
| `/alerts` | Alerts | Manage price alerts |
| `/alerts/create` | Create Alert | Set price threshold and condition |
| `/profit-calculator` | Profit Calculator | Transport cost vs. market price comparison |
| `/transport` | Transport | Browse available trucks |
| `/transport/book` | Book Transport | Book a truck for delivery |
| `/bookings` | My Bookings | Track booked transports |
| `/weather` | Weather Impact | Weather conditions affecting prices |
| `/profile` | Profile | User information |
| `/settings` | Settings | Language and preferences |

---

## API Endpoints

All endpoints are prefixed with `/api/v1`. Authentication uses Firebase Bearer tokens.

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/sync` | Sync Firebase user to local database |
| `GET` | `/auth/profile` | Get authenticated user profile |

### Crops

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/crops` | List all crops |
| `GET` | `/crops/:cropId/markets/:marketId/latest-price` | Latest price for crop at market |
| `GET` | `/crops/:cropId/markets/:marketId/history?days=7` | Historical price data |

### Markets

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/markets` | List all active markets |
| `GET` | `/markets/nearby?lat=&lon=&radius=&cropId=` | Nearby markets with profit data |

### Predictions

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/predictions/:cropId?marketId=` | AI Sell/Wait recommendation |
| `GET` | `/predictions/:cropId/markets/:marketId/forecast` | 7-day AI price forecast |

### Alerts

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/alerts` | Create price alert |
| `GET` | `/alerts` | List user's active alerts |
| `PATCH` | `/alerts/:id` | Toggle alert status |
| `DELETE` | `/alerts/:id` | Remove alert |

### Transport

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/transport/available` | List available trucks |
| `POST` | `/transport/book` | Book a truck |
| `GET` | `/transport/my-bookings` | User's bookings |

### Intelligence

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/intelligence/transport-profit` | Calculate net profit after transport |

### Weather

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/weather?lat=&lon=` | Weather data for location |

> **Swagger UI**: Interactive API documentation at `http://localhost:3000/api/docs`

---

## ML Model Pipeline

### Model Details

| Model | Weight | Strengths | Min Data Points |
|---|---|---|---|
| **Chronos** | 40% | Zero-shot time-series forecasting, captures complex patterns | Any |
| **Prophet** | 30% | Strong weekly/yearly seasonality detection | 14+ |
| **Linear Regression** | 20% | Stable baseline, fast inference | Any |
| **Moving Average** | 10% | Smooths noise, captures short-term trends | Any |

### Ensemble Strategy

```python
weights = {"chronos": 0.40, "prophet": 0.30, "lr": 0.20, "ma": 0.10}

for each forecast day (7 days):
    predicted_price = sum(model_prediction * weight) / total_active_weight
    lower_bound     = sum(model_lower * weight) / total_active_weight
    upper_bound     = sum(model_upper * weight) / total_active_weight
```

### Confidence Calculation

```python
avg_spread = mean([(upper - lower) / predicted for each day])
confidence = max(0.1, 1.0 - avg_spread)
```

### Trend Classification

| Condition | Trend | Recommendation |
|---|---|---|
| Final price > Current price × 1.02 | **UP** | **WAIT** |
| Final price < Current price × 0.98 | **DOWN** | **SELL** |
| Otherwise | **STABLE** | **SELL** |

---

## Installation Guide

### Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Flutter SDK | 3.x | Mobile app development |
| Node.js | 18+ | Backend runtime |
| Python | 3.10+ | ML service runtime |
| PostgreSQL | 15+ | Database (with PostGIS) |
| Redis | 7+ | Caching |
| Docker | Latest | Container orchestration (optional) |
| Firebase CLI | Latest | Auth configuration |

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/agriprice-ai.git
cd agriprice-ai
```

### 2. Start PostgreSQL & Redis

```bash
docker-compose up -d db redis
```

This starts PostGIS-enabled PostgreSQL on port **5432** and Redis on port **6379**.

### 3. Set Up the Database

```bash
# Run the schema
psql -h localhost -U user -d agriprice -f backend/database/schema.sql

# Seed Tamil Nadu market data (38 markets with real GPS coordinates)
psql -h localhost -U user -d agriprice -f backend/database/seed_tn_markets.sql
```

### 4. Start the Backend

```bash
cd backend
npm install
npm run start:dev
```

Backend runs on **http://localhost:3000** — Swagger docs at **http://localhost:3000/api/docs**.

### 5. Start the ML Service

```bash
cd ml-service
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

ML service runs on **http://localhost:8000**.

### 6. Set Up Firebase

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com).
2. Enable **Email/Password** and **Google Sign-In** authentication.
3. Place `google-services.json` in `mobile/android/app/`.
4. Place the Firebase service account JSON in `backend/`.
5. Run `flutterfire configure` from the `mobile/` directory.

### 7. Run the Flutter App

```bash
cd mobile
flutter pub get
flutter run
```

> **Physical Android device tip** — set up ADB reverse port forwarding:
> ```bash
> adb reverse tcp:3000 tcp:3000
> adb reverse tcp:8000 tcp:8000
> ```

---

## Running with Docker

### Development

```bash
# Start all services (DB, Redis, ML Service, Backend)
docker-compose up -d
```

### Production

```bash
cd deployment
docker-compose -f docker-compose.prod.yml up -d
```

Production includes **Nginx reverse proxy** with SSL termination.

### Kubernetes

```bash
kubectl apply -f deployment/kubernetes/secrets.yaml
kubectl apply -f deployment/kubernetes/postgres-deployment.yaml
kubectl apply -f deployment/kubernetes/redis-deployment.yaml
kubectl apply -f deployment/kubernetes/ml-service-deployment.yaml
kubectl apply -f deployment/kubernetes/backend-deployment.yaml
kubectl apply -f deployment/kubernetes/ingress.yaml
```

| Service | Replicas | Resources |
|---|---|---|
| Backend | 2 | Default |
| ML Service | 1 | 512Mi–1Gi RAM, 500m–1000m CPU |
| PostgreSQL | 1 | Persistent volume |
| Redis | 1 | Password auth |

---

## Environment Variables

### Backend (`backend/.env`)

```env
# Server
PORT=3000
API_PREFIX=api/v1
NODE_ENV=development

# Database (PostgreSQL + PostGIS)
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=user
DB_PASSWORD=password
DB_DATABASE=agriprice

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRES_IN=7d

# ML Service
ML_SERVICE_URL=http://localhost:8000

# Weather API (OpenWeatherMap)
WEATHER_API_KEY=your_openweathermap_api_key
WEATHER_API_URL=https://api.openweathermap.org/data/2.5

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json
```

### ML Service (`ml-service/.env`)

```env
ML_HOST=0.0.0.0
ML_PORT=8000
ML_DEBUG=false
FORECAST_STEPS=7
MIN_HIST_POINTS=7
LOG_LEVEL=INFO
```

---

## Database Setup

The database uses **PostgreSQL 15** with the **PostGIS 3.3** extension for geospatial market queries.

### Core Tables

```sql
CREATE EXTENSION IF NOT EXISTS postgis;

users         — Firebase-synced user accounts (UUID PK, firebase_uid, role)
crops         — Crop catalog with English + Tamil names (UUID PK, name_en, name_ta, category)
markets       — Market locations with PostGIS geometry (UUID PK, name_en, location GEOMETRY(Point,4326))
crop_prices   — Historical price records (UUID PK, crop_id FK, market_id FK, price_per_kg, record_date)
predictions   — Cached AI forecasts (UUID PK, predicted_price, confidence_score, model_used)
alerts        — User price alerts (UUID PK, target_price, condition ABOVE/BELOW)
trucks        — Available transport vehicles (UUID PK, capacity_kg, per_km_rate)
bookings      — Transport bookings (UUID PK, user_id FK, truck_id FK, status)
```

### Pre-seeded Data

- **38 Tamil Nadu Uzhavar Sandhai markets** with verified GPS coordinates
- **737,000+ crop price records** across multiple crops and markets
- **20+ crop varieties** with bilingual names (English & Tamil)

---

## Future Improvements

- [ ] Real-time WebSocket price streaming
- [ ] Satellite imagery integration (NDVI crop health)
- [ ] Farmer-to-buyer direct marketplace
- [ ] Government MSP (Minimum Support Price) notifications
- [ ] Hindi, Kannada, and Telugu localization
- [ ] On-device TensorFlow Lite inference for offline predictions
- [ ] Blockchain-based farm-to-fork traceability
- [ ] Farmer community groups and expert Q&A
- [ ] Web analytics dashboard for market trends
- [ ] SMS fallback for low-connectivity areas

---

## Contributing

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/your-feature`
3. **Commit changes**: `git commit -m "Add: your feature description"`
4. **Push**: `git push origin feature/your-feature`
5. **Open a Pull Request**

### Guidelines

- **Backend** — Follow NestJS module conventions (controller + service + entities per module)
- **Mobile** — Follow Clean Architecture layers (presentation → domain → data)
- **ML Service** — New models go in `ml-service/app/models/` and must return `[{"mean", "low", "high"}]`
- **Code Style** — TypeScript: Prettier + ESLint | Dart: flutter_lints | Python: PEP 8

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for Indian farmers
</p>

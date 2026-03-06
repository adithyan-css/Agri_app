<div align="center">

# 🌾 AgriPrice AI

### Crop Price Intelligence for Indian Farmers

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.x-E0234E?logo=nestjs)](https://nestjs.com)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql)](https://postgresql.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Live mandi prices · 7-day AI forecasts · Sell/Wait decisions · Market discovery · Transport profit**

</div>

---

## 📱 Screenshots & Demo

> 🎬 **[Watch the Full Demo Video →](https://drive.google.com/file/d/1UlUzuQ_02DlLu67UCDEGOeNCTLpilq6r/view?usp=drivesdk)**

<div align="center">
<table>
  <tr>
    <td align="center"><b>🏠 Home Screen</b></td>
    <td align="center"><b>🏪 Markets</b></td>
    <td align="center"><b>🤖 AI Analysis</b></td>
    <td align="center"><b>📊 Market Factors</b></td>
  </tr>
  <tr>
    <td><img src="screenshots/home_screen.png" width="220" alt="Home Screen - AI recommendations, crop prices, nearby markets"/></td>
    <td><img src="screenshots/markets_screen.png" width="220" alt="Markets - Browse and filter nearby mandis"/></td>
    <td><img src="screenshots/ai_analysis.png" width="220" alt="AI Analysis - SELL/WAIT recommendation with confidence score"/></td>
    <td><img src="screenshots/ai_analysis_details.png" width="220" alt="Market Factors - Price trend, supply, and potential gain"/></td>
  </tr>
  <tr>
    <td><sub>AI-powered WAIT/SELL recommendations, live crop prices, and nearby market discovery</sub></td>
    <td><sub>92 Tamil Nadu markets with filters — Nearest, Best Price, Under 10km</sub></td>
    <td><sub>87.5% confidence SELL recommendation with 7-day predicted price trend chart</sub></td>
    <td><sub>Price trend (DOWN), market supply (INCREASING), and potential gain analysis</sub></td>
  </tr>
</table>
</div>

---

## The Problem

Indian farmers lose an estimated ₹50,000 crores annually because they sell at the wrong time, at the wrong market, to the wrong buyer. A tomato farmer in Salem might sell at ₹35/kg locally while Coimbatore pays ₹42/kg — but he doesn't know that. And even if he did, he can't tell whether prices will climb further next week, or whether the transport costs will eat the profit.

AgriPrice AI puts that intelligence in his pocket. It pulls live government mandi prices, runs a 4-model AI ensemble to forecast the next 7 days, tells the farmer whether to sell now or wait, finds nearby markets ranked by profit after transport, and does it all in Tamil.

---

## Table of Contents

- [Screenshots & Demo](#-screenshots--demo)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Running with Docker](#running-with-docker)
- [API Overview](#api-overview)
- [ML Pipeline](#ml-pipeline)
- [Database](#database)
- [Deployment](#deployment)
- [How It Works End-to-End](#how-it-works-end-to-end)
- [Future Improvements](#future-improvements)
- [Contributing](#contributing)
- [License](#license)

---

## Key Features

### 📊 Live Mandi Prices
Pulls commodity prices from the Government of India's Open Data API (data.gov.in) every 6 hours via automated cron job. 100+ commodity name mappings across 38+ Tamil Nadu Uzhavar Sandhai APMC markets. Prices are converted from quintal rates to per-kg and stored in PostgreSQL. The mobile app caches prices locally for offline access.

### 🤖 7-Day AI Price Forecasts
Four independent ML models run on 90 days of historical price data and produce a 7-day forecast with confidence intervals:

| Model | Weight | Strength |
|---|---|---|
| **Amazon Chronos** | 40% | Zero-shot foundation model — handles any crop without retraining |
| **Facebook Prophet** | 30% | Captures weekly and seasonal price cycles |
| **Linear Regression** | 20% | Fast baseline for simple trends |
| **Moving Average** | 10% | Noise smoother and stability anchor |

If a model fails (insufficient data, timeout), its weight redistributes to the remaining models automatically.

### 🎯 Sell or Wait Recommendation
Compares today's price against the AI-predicted peak over the next 7 days. If the peak exceeds the current price by more than 2%, it says **WAIT** with a human-readable explanation in English and Tamil. Otherwise, **SELL NOW**. The reasoning includes the predicted peak date and expected gain.

### 📍 GPS-Based Market Discovery
Uses the phone's GPS and PostGIS spatial queries (`ST_DWithin`) to find mandis within a configurable radius. Each market is ranked by net profit after transport costs — not just by distance or raw price.

### 🚚 Transport Profit Calculator
Uses OpenRouteService for real road distances (not straight-line), factors in truck capacity, fuel cost per km, and loading charges.

```
Example:
Tomato 500kg — Salem (₹35/kg) → Coimbatore (₹42/kg, 85km)
Transport cost: ₹1.27/kg
Net Profit: ₹2,862
```

### 🔔 Price Alerts
Set a target price for any crop at any market. An hourly cron job monitors all active alerts and fires push notifications via Firebase Cloud Messaging when thresholds are crossed.

### 🌦️ Weather Integration
Pulls OpenWeatherMap forecasts (temperature, rainfall, humidity) and feeds them into the ML models as features, improving prediction accuracy for weather-sensitive crops.

### 🗣️ Bilingual — English + Tamil
Full localization with ARB files. Voice-to-text search for farmers who find typing difficult. Every recommendation, alert message, and crop name is available in both languages.

### 🚛 Truck Booking
Browse available trucks with capacity and rate details, book directly from the app, and track bookings.

### 📶 Offline Mode
Prices and crop data are cached on-device via SharedPreferences. Core browsing works without internet — predictions require connectivity.

---

## Architecture

```
┌──────────────────────────────────┐
│     Flutter Mobile App           │
│     Riverpod · GoRouter · Dio    │
│     22+ screens · offline cache  │
└──────────────┬───────────────────┘
               │ REST / JSON
               │ Firebase Bearer Token
               ▼
┌──────────────────────────────────┐
│     NestJS Backend API           │
│     13 modules · Firebase Auth   │
│     TypeORM · PostGIS queries    │
│     Swagger at /api/docs         │
└──────┬──────────┬────────────────┘
       │          │
       ▼          ▼
┌────────────┐  ┌──────────────────┐
│ PostgreSQL │  │ FastAPI ML        │
│ 15+PostGIS │  │ Service           │
│ 12 tables  │  │                   │
│ 38+markets │  │ Chronos · Prophet │
├────────────┤  │ LinReg · MovAvg   │
│ Redis 7    │  │ Ensemble blend    │
│ (cache)    │  └──────────────────┘
└────────────┘

External APIs:
├─ data.gov.in ───── Live mandi commodity prices (6h cron)
├─ OpenWeatherMap ── Temperature, rainfall, humidity
├─ OpenRouteService  Road distances & travel times
└─ Firebase ──────── Auth (Google + Email) · Cloud Messaging
```

The mobile app communicates with the NestJS backend over REST. The backend handles authentication (Firebase ID token verification via JWT guard), serves crop/market/price data from PostgreSQL, and proxies prediction requests to the Python ML service. Predictions are cached in the database for 24 hours. The ML service is stateless — it receives historical prices and weather context in the request body and returns a 7-day forecast.

### Prediction Flow

```
User taps "Predict" on Tomato
        │
        ├─ Flutter: GET /predictions/:cropId/markets/:marketId/forecast
        │
        ├─ NestJS: Check DB for cached forecast (generated today?)
        │   ├─ HIT  → Return cached prediction
        │   └─ MISS → Continue ↓
        │
        ├─ Fetch 90-day historical prices from PostgreSQL
        ├─ Fetch weather forecast from OpenWeatherMap
        │
        ├─ POST to ML Service /predict
        │   ├─ Chronos  → [36.5, 38.0, 42.0, 41.0, 39.5, 38.0, 37.0]
        │   ├─ Prophet  → [36.0, 37.5, 41.0, 40.5, 39.0, 37.5, 36.5]
        │   ├─ LinReg   → [36.8, 38.5, 43.0, 42.0, 40.0, 38.5, 37.2]
        │   └─ MovAvg   → [36.2, 37.5, 40.8, 40.0, 38.9, 37.8, 36.9]
        │
        ├─ Weighted ensemble → 7-day forecast + confidence intervals
        ├─ Cache in DB → Return to Flutter
        └─ Render chart
```

---

## Tech Stack

### Mobile
| Technology | Purpose |
|---|---|
| Flutter 3.x / Dart | Cross-platform mobile framework |
| Riverpod | State management |
| GoRouter | Declarative navigation |
| Dio | HTTP client with auth interceptors |
| fl_chart | Price charts and visualizations |
| Geolocator | GPS location |
| speech_to_text | Voice input for search |
| SharedPreferences | Offline price cache |
| Firebase Auth | Google Sign-In + Email/Password |
| intl + flutter_localizations | English and Tamil (ARB-based) |

### Backend
| Technology | Purpose |
|---|---|
| NestJS 10.x / TypeScript | REST API framework |
| TypeORM | Database ORM with migrations |
| Passport + JWT | Authentication strategy |
| @nestjs/schedule | Cron jobs (mandi ingestion, alert monitoring) |
| Swagger / OpenAPI | Auto-generated API documentation |
| Axios | HTTP client for external APIs |
| firebase-admin | Firebase ID token verification, FCM push |
| csv-parser | Historical price data loading |

### Database & Cache
| Technology | Purpose |
|---|---|
| PostgreSQL 15 | Primary data store |
| PostGIS 3.3 | Spatial queries for market discovery |
| Redis 7 | Caching layer |

### Machine Learning
| Technology | Purpose |
|---|---|
| FastAPI 0.104 | ML service API framework |
| Amazon Chronos (transformers) | Zero-shot time-series forecasting |
| Facebook Prophet | Seasonality-aware forecasting |
| scikit-learn | Linear regression model |
| PyTorch 2.1 | Deep learning backend for Chronos |
| pandas / numpy | Data processing |

### Infrastructure
| Technology | Purpose |
|---|---|
| Docker Compose | Container orchestration (dev & prod) |
| Kubernetes | Production manifests (deployments, ingress, secrets) |
| Nginx | Reverse proxy with SSL termination (production) |

---

## Project Structure

```
agri_app/
├── mobile/                          # Flutter app
│   └── lib/
│       ├── main.dart                # Firebase init, Riverpod scope, entry point
│       ├── config/                  # GoRouter routes, theme, constants
│       ├── core/                    # Auth service, Dio client, storage utils
│       ├── data/
│       │   ├── data_sources/
│       │   │   ├── remote/          # 10 API clients (crop, market, prediction, alert...)
│       │   │   └── local/           # SharedPreferences offline cache
│       │   ├── models/              # 12 Dart data models
│       │   └── repositories/        # Repository abstractions
│       ├── domain/                  # Use cases
│       ├── presentation/
│       │   ├── screens/             # 22+ screens (home, prices, predictions, markets...)
│       │   ├── providers/           # 11 Riverpod providers
│       │   └── widgets/             # Reusable cards, charts, forms
│       └── l10n/                    # ARB localization files (EN + TA)
│
├── backend/                         # NestJS API
│   └── src/
│       ├── main.ts                  # Bootstrap, Firebase Admin, Swagger, CORS
│       ├── app.module.ts            # Root module (13 feature modules)
│       ├── config/                  # DB, JWT, Redis, Swagger config
│       ├── common/                  # Guards, decorators, pipes, filters
│       └── modules/
│           ├── auth/                # Firebase sync, JWT guard
│           ├── crops/               # Crop catalog, prices, history
│           ├── markets/             # PostGIS nearby search, profit ranking
│           ├── predictions/         # ML client, forecast cache, sell/wait
│           ├── alerts/              # CRUD + hourly cron price monitor
│           ├── transport/           # Trucks & bookings
│           ├── routing/             # OpenRouteService road distances
│           ├── recommendations/     # Transport profit calculation
│           ├── weather/             # OpenWeatherMap integration
│           ├── mandi-data/          # data.gov.in ingestion (6h cron)
│           ├── ml-service/          # HTTP wrapper for Python ML
│           ├── seed/                # Database bootstrap seeder
│           └── notifications/       # FCM push notifications
│
├── ml-service/                      # Python ML microservice
│   └── app/
│       ├── main.py                  # FastAPI — POST /predict, GET / (health)
│       ├── config.py                # Model weights, forecast horizon
│       ├── services/                # Prediction orchestration
│       ├── models/                  # Chronos, Prophet, LinReg, MovAvg, Ensemble
│       ├── schemas/                 # Pydantic request/response validation
│       └── utils/                   # Data cleaning, feature engineering, metrics
│
├── deployment/
│   ├── docker/                      # Multi-stage Dockerfiles
│   ├── kubernetes/                  # K8s manifests (deployments, ingress, secrets)
│   ├── scripts/                     # DB backup, seed, setup scripts
│   ├── docker-compose.yml           # Dev deployment
│   └── docker-compose.prod.yml      # Prod with Nginx + SSL
│
├── docker-compose.yml               # Quick-start: all 4 services
└── start.ps1                        # One-click Windows launcher
```

---

## Getting Started

### Prerequisites

- **Docker Desktop** — PostgreSQL, Redis, and ML service run in containers
- **Node.js 18+** — NestJS backend
- **Flutter SDK 3.x** — Mobile app
- **Firebase project** — with Authentication enabled (Email/Password + Google Sign-In)

### Quick Start (Windows)

```powershell
git clone https://github.com/adithyan-css/Agri_app.git
cd Agri_app
.\start.ps1
```

This script handles everything: starts Docker Desktop if needed, brings up PostgreSQL/Redis/ML containers, waits for health checks, starts the NestJS backend, sets up ADB port forwarding, and launches the Flutter app on your connected device.

Options:
```powershell
.\start.ps1                    # Auto-detect Android device
.\start.ps1 -Device chrome     # Run on Chrome
.\start.ps1 -SkipFlutter       # Start services only
```

### Manual Setup

**1. Clone and start infrastructure:**
```bash
git clone https://github.com/adithyan-css/Agri_app.git
cd Agri_app
docker-compose up -d db redis ml-service
```

**2. Set up the backend:**
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your API keys (see Environment Variables below)
```

**3. Start the backend:**
```bash
npx nest start
```
Backend runs at `http://localhost:3000`. Swagger docs at `http://localhost:3000/api/docs`.

**4. Set up Firebase:**
- Create a project at [console.firebase.google.com](https://console.firebase.google.com)
- Enable Email/Password and Google Sign-In under Authentication
- Download `google-services.json` → place in `mobile/android/app/`
- Generate a service account key → place in `backend/` as `firebase-service-account.json`
- Run `flutterfire configure` from the `mobile/` directory

**5. Run the Flutter app:**
```bash
cd mobile
flutter pub get
flutter run
```

For a physical Android device via USB:
```bash
adb reverse tcp:3000 tcp:3000   # Backend
adb reverse tcp:8000 tcp:8000   # ML Service
flutter run
```

### Troubleshooting

**Port 3000 in use:**
```bash
# Linux/Mac
lsof -ti:3000 | xargs kill -9

# Windows PowerShell
Get-NetTCPConnection -LocalPort 3000 | Select -Expand OwningProcess | % { Stop-Process -Id $_ -Force }
```

**Docker containers won't start:**
```bash
docker-compose down -v
docker-compose up -d
```

**Flutter build errors:**
```bash
flutter clean && flutter pub get && flutter run
```

---

## Environment Variables

### Backend (`backend/.env`)

| Variable | Required | Description |
|---|---|---|
| `PORT` | No | Server port (default: `3000`) |
| `DB_HOST` | Yes | PostgreSQL host (default: `localhost`) |
| `DB_PORT` | Yes | PostgreSQL port (default: `5432`) |
| `DB_USERNAME` | Yes | Database user |
| `DB_PASSWORD` | Yes | Database password |
| `DB_DATABASE` | Yes | Database name (default: `agriprice`) |
| `DB_SYNC` | No | TypeORM schema sync — set `false` in production |
| `JWT_SECRET` | Yes | JWT signing key |
| `ML_SERVICE_URL` | Yes | Python ML service URL (default: `http://localhost:8000`) |
| `OPENWEATHER_API_KEY` | Yes | [OpenWeatherMap](https://openweathermap.org/api) API key |
| `DATA_GOV_API_KEY` | Yes | [data.gov.in](https://data.gov.in/) API key for mandi prices |
| `OPENROUTE_API_KEY` | Yes | [OpenRouteService](https://openrouteservice.org/) API key |

A template is provided at `backend/.env.example` — copy it and fill in your keys.

---

## Running with Docker

### Development

The root `docker-compose.yml` starts the full stack:

```bash
docker-compose up -d
```

| Container | Port | Image |
|---|---|---|
| PostgreSQL 15 + PostGIS | 5432 | `postgis/postgis:15-3.3` |
| Redis 7 | 6379 | `redis:7-alpine` |
| ML Service | 8000 | Built from `./ml-service/Dockerfile` |
| Backend | 3000 | Built from `./backend/Dockerfile` |

PostgreSQL data persists in a named volume (`pgdata`).

### Production

```bash
cd deployment
docker-compose -f docker-compose.prod.yml up -d
```

Production adds:
- **Nginx** reverse proxy with SSL termination (ports 80/443)
- Redis password authentication
- `restart: always` on all services
- Environment variables via `.env` file substitution
- `NODE_ENV=production`, `ML_DEBUG=false`

---

## API Overview

**Base URL:** `http://localhost:3000/api/v1`
**Auth:** All endpoints require `Authorization: Bearer <firebase_token>` header.
**Docs:** Swagger UI at `http://localhost:3000/api/docs`

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/sync` | Sync Firebase user to local database |
| GET | `/auth/profile` | Get current user profile |

### Crops & Prices
| Method | Endpoint | Description |
|---|---|---|
| GET | `/crops` | All crops catalog |
| GET | `/crops/market/:marketId/prices` | Latest price for every crop at a market |
| GET | `/crops/:cropId/markets/:marketId/latest-price` | Latest price for one crop at one market |
| GET | `/crops/:cropId/markets/:marketId/history?days=30` | Historical price data |

### Markets
| Method | Endpoint | Description |
|---|---|---|
| GET | `/markets` | All active markets |
| GET | `/markets/nearby?lat=&lon=&radius=&cropId=` | Nearby markets ranked by profit |

### Predictions
| Method | Endpoint | Description |
|---|---|---|
| GET | `/predictions/:cropId/markets/:marketId/forecast` | 7-day AI forecast with confidence intervals |
| GET | `/predictions/:cropId?marketId=` | Sell/Wait recommendation |

### Alerts
| Method | Endpoint | Description |
|---|---|---|
| POST | `/alerts` | Create price alert |
| GET | `/alerts` | Get user's active alerts |
| PATCH | `/alerts/:id` | Toggle alert status |
| DELETE | `/alerts/:id` | Deactivate alert |

### Transport
| Method | Endpoint | Description |
|---|---|---|
| GET | `/transport/available` | Available trucks |
| POST | `/transport/book` | Book a truck |
| GET | `/transport/my-bookings` | User's bookings |

### Intelligence
| Method | Endpoint | Description |
|---|---|---|
| POST | `/intelligence/transport-profit` | Net profit calculator (manual distance) |
| POST | `/transport-profit` | Net profit with real road distance (OpenRouteService) |

### Weather
| Method | Endpoint | Description |
|---|---|---|
| GET | `/weather?lat=&lon=` | Weather data for coordinates |

### Users
| Method | Endpoint | Description |
|---|---|---|
| GET | `/users/me/preferred-market` | Get preferred market |
| PATCH | `/users/me/preferred-market` | Set preferred market |

---

## ML Pipeline

The Python ML service (`ml-service/`) runs on FastAPI and exposes a single prediction endpoint at `POST /predict`.

### Models

**Chronos (40% weight)** — Amazon's zero-shot time-series foundation model from the Hugging Face `transformers` library. Works on any crop without fine-tuning. Strongest contributor to the ensemble.

**Prophet (30% weight)** — Facebook's additive regression model. Captures weekly and yearly seasonality patterns common in agricultural commodity cycles. Requires at least 14 data points.

**Linear Regression (20% weight)** — scikit-learn OLS regression on engineered features (calendar, price lag, rolling stats). Fast, interpretable baseline.

**Moving Average (10% weight)** — Weighted moving average with exponential decay. Smooths daily noise and serves as a stability anchor.

### Ensemble

```
predicted_price[day] = Σ(model_price[day] × weight) / Σ(active_weights)
```

If a model fails, its weight is redistributed proportionally to the remaining models.

### Confidence & Trend

**Confidence score** — Based on the average spread between upper and lower bounds relative to the predicted price. Tighter bounds = higher confidence.

**Trend classification:**

| Condition | Trend | Action |
|---|---|---|
| Predicted peak > current × 1.02 | UP | **WAIT** — prices rising |
| Predicted peak < current × 0.98 | DOWN | **SELL** — prices falling |
| Otherwise | STABLE | **SELL** — no significant movement |

### Feature Engineering

The `utils/feature_engineer.py` module generates features for the regression model:
- Calendar features (day of week, month, quarter)
- Price features (lag values, rolling mean, rolling std, rate of change)
- Weather features (temperature, rainfall, humidity)
- Supply features (arrival volume trends)

---

## Database

**PostgreSQL 15** with the **PostGIS 3.3** extension. 12 tables:

| Table | Purpose |
|---|---|
| `users` | Firebase-synced accounts (firebase_uid, phone, name, role, GPS, FCM token) |
| `otp_verifications` | Phone OTP codes with expiry |
| `crops` | Crop catalog — bilingual names (EN/TA), category, shelf life |
| `markets` | Market locations — bilingual names, district, state, PostGIS `GEOGRAPHY(Point)` |
| `crop_prices` | Historical price records per crop × market × date, quality grade, source |
| `market_arrivals` | Volume of crop arrivals at each market per day |
| `weather_data` | Cached weather forecasts per market |
| `predictions` | AI forecast cache — predicted price, confidence, bounds, model |
| `recommendations` | Sell/Wait recommendations with bilingual reasoning |
| `user_preferences` | Per-user crop watchlist with target prices |
| `alerts` | Price alerts — crop, type, bilingual messages, read status |
| `notifications` | Push notification log — title, body, delivery status |

**Key indexes:** GIST spatial index on `markets.location` for fast nearby queries. Composite index on `crop_prices(crop_id, market_id, record_date)`.

### Seeded Data

On first startup, the backend seeds:
- 50+ crops with English and Tamil names across vegetables, fruits, grains, and spices
- 38+ Tamil Nadu Uzhavar Sandhai APMC markets with verified GPS coordinates
- Historical price records per crop-market pair
- Sample trucks with capacity and rates

The mandi data cron job then ingests live prices from data.gov.in every 6 hours, automatically matching 100+ commodity names to seeded crops and converting quintal prices to per-kg.

### Data Sources

| Source | Data | Method |
|---|---|---|
| **data.gov.in** | Live mandi commodity prices | 6-hour cron, 100+ TN commodity mappings, quintal→kg conversion |
| **OpenWeatherMap** | Temperature, rainfall, humidity | On-demand per market, fed into ML models |
| **OpenRouteService** | Road distances, travel times | Driving profile, used for transport profit |
| **Firebase** | User auth, push notifications | Google + Email auth, FCM |

---

## Deployment

### Docker Compose

Development:
```bash
docker-compose up -d
```

Production (with Nginx, SSL, Redis auth):
```bash
cd deployment
docker-compose -f docker-compose.prod.yml up -d
```

### Kubernetes

Kubernetes manifests are provided in `deployment/kubernetes/`:

| Manifest | Purpose |
|---|---|
| `backend-deployment.yaml` | NestJS backend pods + service |
| `ml-service-deployment.yaml` | ML service pods + service |
| `postgres-deployment.yaml` | PostgreSQL + PostGIS with PVC |
| `redis-deployment.yaml` | Redis with PVC |
| `ingress.yaml` | Ingress controller routing |
| `secrets.yaml` | Environment secrets (DB creds, API keys, JWT) |

### Database Backup

```bash
cd deployment/scripts
./backup-db.sh
```

---

## How It Works End-to-End

A farmer opens the app → Firebase authenticates them → the backend syncs their user record.

They browse prices → the app fetches the crop list and latest prices from the backend, which serves data from PostgreSQL (seeded data + live mandi prices ingested every 6 hours).

They tap **"Predict"** on a crop → the Flutter provider calls the forecast endpoint → the backend checks if today's forecast exists in the DB cache. If not, it fetches 90 days of historical prices, grabs the weather forecast from OpenWeatherMap, and POSTs everything to the Python ML service. The ML service runs all 4 models, blends their outputs, and returns a 7-day forecast with confidence intervals. The backend caches the result and returns it. The app renders a line chart.

They tap **"AI Analysis"** → the backend compares the current price against the forecast peak. If prices are trending up by >2%, it says WAIT with a human-readable reason in English and Tamil. Otherwise, SELL.

They tap **"Nearby Markets"** → the app sends GPS coordinates → the backend runs a PostGIS spatial query, fetches the latest price at each nearby market, calls OpenRouteService for real road distances, and returns markets ranked by net profit after transport.

They set a **price alert** → the backend stores it. An hourly cron job checks all active alerts against the latest prices and sends a push notification via Firebase Cloud Messaging when a threshold crosses.

---

## Future Improvements

- **ML model persistence** — Save trained model weights to avoid retraining on every cold start
- **Redis caching layer** — Cache frequently accessed price queries and crop lists beyond DB caching
- **Rate limiting** — Protect endpoints from abuse with request throttling
- **Push notification tracking** — Monitor FCM delivery success rates and retry failures
- **WebSocket streaming** — Real-time price updates instead of polling
- **Satellite imagery** — NDVI crop health monitoring via remote sensing
- **On-device ML** — TensorFlow Lite for fully offline predictions
- **Additional languages** — Hindi, Kannada, Telugu localization
- **SMS fallback** — Price alerts via SMS for low-connectivity areas
- **Farmer marketplace** — Direct farmer-to-buyer transactions
- **Government MSP alerts** — Notify when prices fall below Minimum Support Price
- **Web dashboard** — Analytics portal for market trends and historical patterns

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes and commit: `git commit -m "Add: description"`
4. Push and open a Pull Request

### Code Style

| Layer | Tool | Command |
|---|---|---|
| Backend (TypeScript) | Prettier + ESLint | `cd backend && npm run lint` |
| Mobile (Dart) | flutter_lints | `cd mobile && flutter analyze` |
| ML Service (Python) | PEP 8 / Black | `cd ml-service && black app/` |

### Conventions

- Backend follows the NestJS module pattern — controller + service + entity per module
- Mobile follows Clean Architecture — presentation → domain → data
- ML models go in `ml-service/app/models/` and must return `[{mean, low, high}]` per forecast day
- Commit messages: `Add:`, `Fix:`, `Update:`, `Docs:`

### Running Tests

```bash
cd backend && npm test           # Backend unit tests
cd mobile && flutter test        # Widget and unit tests
cd ml-service && pytest          # ML service tests
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built for Indian farmers. Technology for social good.** 🌾

</div>

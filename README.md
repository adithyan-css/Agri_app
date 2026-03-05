# AgriPrice AI

**An AI-powered mobile platform that helps Indian farmers get better prices for their crops.**

Farmers in India lose a significant chunk of their income simply because they don't have visibility into what their produce is worth at different markets. AgriPrice AI fixes that — it pulls live mandi prices, runs AI forecasts to predict where prices are headed, tells you whether to sell now or wait, finds the nearest high-paying market, and even calculates whether it's worth the transport cost to get there.

The system is built as three services: a Flutter mobile app for the farmer's hands, a NestJS API backend that coordinates everything, and a Python ML microservice that runs a 4-model ensemble for price prediction.

---

## What It Does

**Real-time mandi prices** — Pulls commodity prices from the Government of India's Open Data API (data.gov.in) every 6 hours and stores them locally. Works offline too — prices are cached on the phone.

**7-day AI price forecasts** — Runs historical price data through four different ML models (Chronos, Prophet, Linear Regression, Moving Average), blends their outputs with learned weights, and produces a 7-day forecast with confidence intervals.

**Sell or Wait recommendation** — Compares today's price against the AI forecast. If prices are trending up by more than 2%, it tells the farmer to wait. Otherwise, sell now.

**Nearby market discovery** — Uses the phone's GPS and PostGIS spatial queries to find markets within a given radius, ranked by which ones offer the best price after transport costs.

**Transport profit calculator** — Uses OpenRouteService for real road distances (not straight-line), factors in truck capacity, fuel cost per km, and loading charges to calculate net profit at each market.

**Price alerts** — Set a target price for any crop at any market. A cron job checks hourly and sends a push notification when the price crosses your threshold.

**Weather impact** — Pulls OpenWeatherMap forecasts and feeds temperature, rainfall, and humidity into the prediction models as features.

**Truck booking** — Browse available trucks, see their rates and capacity, and book one.

**Bilingual** — Full English and Tamil localization, including voice input for search.

---

## Architecture

```
┌──────────────────────────────────┐
│     Flutter Mobile App           │
│     (Riverpod + GoRouter + Dio)  │
│     22 screens, offline cache    │
└──────────────┬───────────────────┘
               │ REST / JSON
               ▼
┌──────────────────────────────────┐
│     NestJS Backend               │
│     15 modules, Firebase Auth    │
│     TypeORM, PostGIS queries     │
│     Swagger docs at /api/docs    │
└──────┬──────────────┬────────────┘
       │              │
       ▼              ▼
┌─────────────┐  ┌─────────────────────┐
│ FastAPI ML   │  │ PostgreSQL 15       │
│ Service      │  │ + PostGIS 3.3       │
│              │  │ 12 tables           │
│ Chronos 40%  │  ├─────────────────────┤
│ Prophet 30%  │  │ Redis 7             │
│ LinReg  20%  │  │ (cache)             │
│ MovAvg  10%  │  └─────────────────────┘
└─────────────┘
```

The mobile app talks to the NestJS backend over REST. The backend handles auth (Firebase ID token verification), serves crop/market/price data from PostgreSQL, and proxies prediction requests to the ML service. Predictions are cached for 24 hours to avoid redundant ML calls. The ML service is stateless — it receives historical price data and weather context in the request body and returns a 7-day forecast.

### How a Prediction Works

```
User taps "Predict" on a crop
        │
        ▼
Flutter Provider ───► GET /predictions/:cropId/markets/:marketId/forecast
        │
        ▼
NestJS PredictionsService
  ├─ Check DB cache (forecast generated today?) ──► YES → return cached
  └─ NO → Fetch 90-day historical prices
         Fetch weather forecast (OpenWeatherMap)
         POST to ML Service /predict
              │
              ▼
         FastAPI runs all 4 models
           ├─ Chronos  (40% weight)
           ├─ Prophet  (30% weight)
           ├─ LinReg   (20% weight)
           └─ MovAvg   (10% weight)
           ──► Weighted ensemble → 7-day forecast
              │
              ▼
         Cache in DB → Return to Flutter
         Render chart + confidence intervals
```

### How Sell/Wait Works

The backend fetches the latest market price and the 7-day AI forecast. If the highest predicted price exceeds today's price by more than 2%, it recommends WAIT (prices are trending up). Otherwise, SELL. It returns a human-readable reason in both English and Tamil.

---

## Tech Stack

| Component | Technology |
|---|---|
| Mobile | Flutter 3.x, Dart |
| State management | Riverpod |
| Navigation | GoRouter |
| HTTP | Dio with auth interceptors |
| Auth | Firebase Authentication (Google + Email/Password) |
| Backend | NestJS 10.x, TypeScript |
| ORM | TypeORM |
| Database | PostgreSQL 15 + PostGIS 3.3 |
| Cache | Redis 7 |
| ML service | FastAPI 0.104, Python 3.10+ |
| ML models | Amazon Chronos (transformers), Facebook Prophet, scikit-learn |
| Deep learning | PyTorch 2.1 |
| Charts | fl_chart |
| Voice | speech_to_text |
| Localization | English + Tamil (intl + flutter_localizations) |
| Push notifications | Firebase Cloud Messaging |
| Geospatial | PostGIS (ST_DWithin, ST_Distance), Geolocator |
| Road routing | OpenRouteService API |
| Weather | OpenWeatherMap API |
| Mandi data | data.gov.in Open Data API |
| API docs | Swagger / OpenAPI |
| Deployment | Docker Compose, Kubernetes, Nginx |

---

## Project Layout

```
agri_app/
├── mobile/                     # Flutter app
│   └── lib/
│       ├── main.dart           # Entry point, Firebase init, Riverpod scope
│       ├── config/             # Routes (GoRouter), theme, app constants
│       ├── core/               # Auth service, Dio client, storage, utils
│       ├── data/
│       │   ├── data_sources/
│       │   │   ├── remote/     # 10 API clients (crop, market, prediction, alert, etc.)
│       │   │   └── local/      # SharedPreferences offline cache
│       │   ├── models/         # 12 Dart data models (fromJson/toJson)
│       │   └── repositories/   # 10 repository classes
│       ├── domain/             # 4 use cases (get_crop_prices, get_nearby_markets, etc.)
│       ├── presentation/
│       │   ├── screens/        # 22 screens
│       │   ├── providers/      # 11 Riverpod providers
│       │   └── widgets/        # 15+ reusable widgets (charts, cards, forms)
│       └── l10n/               # ARB files for EN and TA
│
├── backend/                    # NestJS API
│   └── src/
│       ├── main.ts             # Bootstrap, Firebase Admin init, Swagger, CORS
│       ├── app.module.ts       # Root module (15 feature modules)
│       ├── config/             # DB, JWT, Redis, Swagger config
│       ├── common/             # Guards, decorators, pipes, interceptors, filters
│       └── modules/
│           ├── auth/           # POST /auth/sync, GET /auth/profile
│           ├── users/          # User entity, preferred market
│           ├── crops/          # Crop + CropPrice entities, history endpoint
│           ├── markets/        # PostGIS nearby search, profit-aware discovery
│           ├── predictions/    # ML service client, 24h cache, sell/wait logic
│           ├── recommendations/# Manual transport profit calculation
│           ├── routing/        # OpenRouteService road distance API
│           ├── transport/      # Truck + Booking entities, CRUD
│           ├── alerts/         # Alert CRUD + hourly cron price monitor
│           ├── weather/        # OpenWeatherMap integration
│           ├── ml-service/     # HTTP wrapper for Python ML service
│           ├── mandi-data/     # data.gov.in ingestion, 6h cron, 100+ commodity mappings
│           ├── seed/           # Bootstrap seeder (crops, markets, prices, trucks)
│           └── notifications/  # FCM push notification service
│
├── ml-service/                 # Python ML microservice
│   └── app/
│       ├── main.py             # FastAPI app, POST /predict, health check
│       ├── config.py           # Model weights, forecast horizon, thresholds
│       ├── services/
│       │   └── prediction_service.py  # Orchestrates ensemble prediction
│       ├── models/
│       │   ├── chronos_forecaster.py  # Amazon Chronos (zero-shot time-series)
│       │   ├── prophet_model.py       # Facebook Prophet
│       │   ├── linear_regression.py   # scikit-learn LinearRegression
│       │   ├── moving_average.py      # Weighted moving average
│       │   └── ensemble.py            # Weighted blend of all models
│       ├── schemas/            # Pydantic request/response validation
│       └── utils/
│           ├── data_processor.py      # Outlier removal, interpolation, cleaning
│           ├── feature_engineer.py    # Calendar, weather, price, supply features
│           ├── validators.py          # Input validation
│           └── metrics.py             # MAE, RMSE, MAPE evaluation
│
├── deployment/
│   ├── docker/                 # Multi-stage Dockerfiles (backend, ml-service, nginx)
│   ├── kubernetes/             # Deployments, services, ingress, secrets
│   ├── scripts/                # DB backup, seed, setup shell scripts
│   ├── docker-compose.yml      # Dev deployment
│   └── docker-compose.prod.yml # Prod with Nginx reverse proxy + SSL
│
├── docker-compose.yml          # Quick-start: PostgreSQL, Redis, ML service, backend
└── start.ps1                   # One-click Windows launcher (Docker + backend + Flutter)
```

---

## Database

PostgreSQL 15 with the PostGIS extension. 12 tables:

| Table | What it stores |
|---|---|
| `users` | Firebase-synced accounts (firebase_uid, phone, name, role, GPS location, FCM token) |
| `otp_verifications` | Phone number OTP codes with expiry |
| `crops` | Crop catalog — bilingual names (EN/TA), category, shelf life |
| `markets` | Market locations — bilingual names, district, state, PostGIS GEOGRAPHY(Point) |
| `crop_prices` | Historical price records — crop, market, price_per_kg, date, quality grade, source |
| `market_arrivals` | Volume of crop arrivals at each market per day |
| `weather_data` | Cached weather forecasts per market (temp, rainfall, humidity) |
| `predictions` | AI forecast cache — predicted price, confidence, bounds, model used |
| `recommendations` | Sell/Wait recommendations with bilingual reasoning |
| `user_preferences` | Per-user crop watchlist with target prices and notification flags |
| `alerts` | Price alerts — crop, alert type, bilingual messages, read status |
| `notifications` | Push notification log — title, body, sent/pending/failed status |

Key indexes: GIST spatial index on `markets.location` for fast nearby queries, composite indexes on `crop_prices(crop_id, market_id, record_date)`.

### Seeded Data

The backend auto-seeds on first startup and also ingests live data:
- 5 core crops with Tamil names (Rice, Tomato, Onion, Potato, Banana)
- 4 Tamil Nadu markets with verified GPS coordinates
- 30 days of synthetic price history per crop-market pair
- 3 trucks with varying capacity and rates
- Every 6 hours: live mandi prices from data.gov.in for 100+ Tamil Nadu commodities across all active markets

---

## ML Pipeline

The prediction service runs four models independently and blends their outputs:

| Model | Weight | Why |
|---|---|---|
| **Chronos** | 40% | Amazon's zero-shot time-series foundation model. Handles arbitrary crops without retraining. Strongest overall. |
| **Prophet** | 30% | Facebook's seasonality-aware model. Good at weekly/yearly price cycles common in agriculture. Needs 14+ data points. |
| **Linear Regression** | 20% | Fast, interpretable baseline. Captures simple trends. |
| **Moving Average** | 10% | Smooths out daily noise. Useful as a sanity check against the heavier models. |

**Ensemble formula:**
```
predicted_price[day] = Σ(model_price[day] × weight) / Σ(active_weights)
```

If a model fails (not enough data, timeout), its weight is redistributed to the remaining models.

**Confidence score:** Based on the average spread between upper and lower bounds relative to the predicted price. Tighter bounds = higher confidence.

**Trend classification:**

| Condition | Trend | Recommendation |
|---|---|---|
| Predicted peak > current × 1.02 | UP | WAIT |
| Predicted peak < current × 0.98 | DOWN | SELL |
| Otherwise | STABLE | SELL |

---

## API Endpoints

Base URL: `http://localhost:3000/api/v1` — Authenticated endpoints require a Firebase Bearer token.

### Auth
| Method | Path | Description |
|---|---|---|
| POST | `/auth/sync` | Sync Firebase user to local DB |
| GET | `/auth/profile` | Current user profile |

### Crops
| Method | Path | Description |
|---|---|---|
| GET | `/crops` | All crops |
| GET | `/crops/:cropId/markets/:marketId/latest-price` | Latest price at a specific market |
| GET | `/crops/:cropId/markets/:marketId/history?days=30` | Price history |

### Markets
| Method | Path | Description |
|---|---|---|
| GET | `/markets` | All active markets |
| GET | `/markets/nearby?lat=&lon=&radius=&cropId=` | Nearby markets with profit ranking |

### Predictions
| Method | Path | Description |
|---|---|---|
| GET | `/predictions/:cropId/markets/:marketId/forecast` | 7-day AI forecast |
| GET | `/predictions/:cropId?marketId=` | Sell/Wait recommendation |

### Alerts
| Method | Path | Description |
|---|---|---|
| POST | `/alerts` | Create price alert |
| GET | `/alerts` | User's active alerts |
| PATCH | `/alerts/:id` | Update alert |
| DELETE | `/alerts/:id` | Delete alert |

### Transport
| Method | Path | Description |
|---|---|---|
| GET | `/transport/available` | Available trucks |
| POST | `/transport/book` | Book a truck |
| GET | `/transport/my-bookings` | User's bookings |

### Intelligence
| Method | Path | Description |
|---|---|---|
| POST | `/intelligence/transport-profit` | Net profit after transport (manual distance) |
| POST | `/transport-profit` | Net profit with real road distance via OpenRouteService |

### Weather
| Method | Path | Description |
|---|---|---|
| GET | `/weather?lat=&lon=` | Weather at location |

Swagger UI: `http://localhost:3000/api/docs`

---

## Data Sources

| Source | What | How |
|---|---|---|
| **data.gov.in** | Live mandi commodity prices (dataset `9ef84268`) | Cron job every 6h, 100+ TN commodity mappings, auto-creates markets, quintal-to-kg conversion |
| **OpenWeatherMap** | Temperature, rainfall, humidity forecasts | On-demand per market, fed into ML models as features |
| **OpenRouteService** | Real road distances and travel times | Driving-car profile, used for transport profit calculation |
| **Firebase** | User authentication, push notifications | Google Sign-In + Email/Password, FCM for price alerts |

---

## Getting Started

### Prerequisites

- **Docker Desktop** — for PostgreSQL, Redis, and the ML service
- **Node.js 18+** — for the NestJS backend
- **Flutter SDK 3.x** — for the mobile app
- **Firebase project** — with Auth enabled (Email/Password + Google Sign-In)

### Quick Start (Windows)

There's a PowerShell script that starts everything in one shot:

```powershell
.\start.ps1
```

It starts Docker Desktop (if not running), brings up the containers (PostgreSQL, Redis, ML service), starts the NestJS backend locally, sets up ADB reverse ports, and launches the Flutter app on a connected Android device.

### Manual Setup

**1. Clone and start infrastructure:**
```bash
git clone https://github.com/adithyan-css/Agri_app.git
cd Agri_app
docker-compose up -d db redis ml-service
```

**2. Configure the backend:**
```bash
cd backend
npm install
```

Create `backend/.env`:
```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_DATABASE=agriprice
DB_SYNC=false
JWT_SECRET=your_secret
ML_SERVICE_URL=http://localhost:8000
OPENWEATHER_API_KEY=your_key
DATA_GOV_API_KEY=your_key
OPENROUTE_API_KEY=your_key
```

**3. Start the backend:**
```bash
npx nest start
```

Backend at `http://localhost:3000`. Swagger at `http://localhost:3000/api/docs`.

**4. Set up Firebase:**
- Create a project at [console.firebase.google.com](https://console.firebase.google.com)
- Enable Email/Password and Google Sign-In
- Place `google-services.json` in `mobile/android/app/`
- Place the Firebase Admin service account JSON in `backend/`
- Run `flutterfire configure` from `mobile/`

**5. Run the Flutter app:**
```bash
cd mobile
flutter pub get
flutter run
```

For a physical Android device, set up port forwarding:
```bash
adb reverse tcp:3000 tcp:3000
adb reverse tcp:8000 tcp:8000
```

---

## Environment Variables

### Backend (`backend/.env`)

| Variable | Purpose |
|---|---|
| `PORT` | Server port (default: 3000) |
| `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE` | PostgreSQL connection |
| `DB_SYNC` | TypeORM auto-sync schema (set `false` in production) |
| `JWT_SECRET` | JWT signing key |
| `ML_SERVICE_URL` | Python ML service URL (default: `http://localhost:8000`) |
| `OPENWEATHER_API_KEY` | OpenWeatherMap API key |
| `DATA_GOV_API_KEY` | data.gov.in API key for mandi prices |
| `OPENROUTE_API_KEY` | OpenRouteService API key for road distances |

### Docker Compose

The root `docker-compose.yml` spins up 4 containers: PostgreSQL 15 + PostGIS (port 5432), Redis 7 (port 6379), ML service (port 8000), and the backend (port 3000). PostgreSQL uses a named volume (`pgdata`) for persistence.

---

## How It Works End-to-End

A farmer opens the app → Firebase authenticates them → the backend syncs their user record.

They browse crops → the app fetches the crop list and latest prices from the backend, which serves data from PostgreSQL (seeded + live mandi ingestion).

They tap "Predict" on a crop → the Flutter provider calls `GET /predictions/:cropId/markets/:marketId/forecast` → the backend checks if a forecast was already generated today. If not, it fetches 90 days of historical prices, grabs the weather forecast from OpenWeatherMap, and POSTs everything to the Python ML service. The ML service runs all 4 models, blends them, and returns a 7-day forecast. The backend caches the result and returns it. The app renders a line chart with confidence intervals.

They tap "AI Analysis" → the backend compares today's price against the forecast peak. If prices are trending up by >2%, it says WAIT with a human-readable reason. Otherwise, SELL.

They tap "Nearby Markets" → the app sends GPS coordinates to `GET /markets/nearby` → the backend runs a PostGIS `ST_DWithin` query, fetches the latest price at each nearby market, calculates transport profit estimates, and returns markets ranked by net profit.

They set a price alert → the backend stores it. An hourly cron job checks all active alerts against the latest prices and fires push notifications when thresholds are crossed.

---

## Future Improvements

- Real-time WebSocket price streaming
- Satellite imagery integration (NDVI crop health monitoring)
- Farmer-to-buyer direct marketplace
- Government MSP (Minimum Support Price) alerts
- Hindi, Kannada, and Telugu localization
- On-device TensorFlow Lite for offline predictions
- Farmer community groups and expert Q&A
- Web analytics dashboard
- SMS fallback for low-connectivity areas

---

## Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m "Add: description"`
4. Push and open a PR

**Conventions:** Backend follows NestJS module pattern (controller + service + entity per module). Mobile follows Clean Architecture (presentation → domain → data). ML models go in `ml-service/app/models/` and must return `[{mean, low, high}]` per forecast day. Code style: Prettier + ESLint (TypeScript), flutter_lints (Dart), PEP 8 (Python).

---

## License

MIT

---

<p align="center">Built for Indian farmers.</p>

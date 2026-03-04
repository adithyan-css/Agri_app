-- AgriPrice AI PostgreSQL Database Schema
-- Requires PostGIS extension for geographic queries
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    preferred_language VARCHAR(10) DEFAULT 'ta', -- 'en' or 'ta'
    location GEOGRAPHY(Point, 4326), -- Farmer's default GPS location
    device_fcm_token VARCHAR(255),
    role VARCHAR(20) DEFAULT 'FARMER',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. OTP Verifications
CREATE TABLE otp_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_otp_phone ON otp_verifications(phone_number);

-- 3. Crops Catalog
CREATE TABLE crops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en VARCHAR(100) NOT NULL,
    name_ta VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    image_url TEXT,
    base_shelf_life_days INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Markets
CREATE TABLE markets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en VARCHAR(100) NOT NULL,
    name_ta VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    state VARCHAR(50) DEFAULT 'Tamil Nadu',
    location GEOGRAPHY(Point, 4326) NOT NULL, -- Mandatory for nearby search
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- PostGIS spatial index for extremely fast Haversine searches
CREATE INDEX idx_markets_location ON markets USING GIST(location);

-- 5. Crop Prices (Historical & Current Market Prices)
CREATE TABLE crop_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID REFERENCES crops(id) ON DELETE CASCADE,
    market_id UUID REFERENCES markets(id) ON DELETE CASCADE,
    price_per_kg DECIMAL(10, 2) NOT NULL,
    record_date DATE NOT NULL,
    quality_grade VARCHAR(20) DEFAULT 'A',
    source VARCHAR(50) DEFAULT 'Agmarknet',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(crop_id, market_id, record_date, quality_grade)
);
CREATE INDEX idx_crop_prices_date ON crop_prices(record_date);
CREATE INDEX idx_crop_prices_market ON crop_prices(market_id);
CREATE INDEX idx_crop_prices_crop ON crop_prices(crop_id);

-- 6. Market Arrivals (Supply Volume Intelligence)
CREATE TABLE market_arrivals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID REFERENCES crops(id),
    market_id UUID REFERENCES markets(id),
    volume_tonnes DECIMAL(10, 2) NOT NULL,
    arrival_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(crop_id, market_id, arrival_date)
);

-- 7. Weather Data (Historical & Forecast context)
CREATE TABLE weather_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    market_id UUID REFERENCES markets(id),
    forecast_date DATE NOT NULL,
    temp_celsius DECIMAL(5, 2),
    rainfall_mm DECIMAL(8, 2),
    humidity_percent INTEGER,
    conditions VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(market_id, forecast_date)
);

-- 8. Predictions (ML Output caching)
CREATE TABLE predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID REFERENCES crops(id),
    market_id UUID REFERENCES markets(id),
    target_date DATE NOT NULL,
    predicted_price DECIMAL(10, 2) NOT NULL,
    confidence_score DECIMAL(5, 4),
    lower_bound DECIMAL(10, 2),
    upper_bound DECIMAL(10, 2),
    model_used VARCHAR(50),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(crop_id, market_id, target_date, model_used)
);
CREATE INDEX idx_predictions_target_date ON predictions(target_date);

-- 9. Recommendations (Business Logic Output)
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID REFERENCES crops(id),
    market_id UUID REFERENCES markets(id),
    action VARCHAR(10) NOT NULL, -- 'SELL', 'WAIT'
    reasoning_en TEXT,
    reasoning_ta TEXT,
    valid_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Alerts & User Preferences
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES crops(id),
    preferred_market_id UUID REFERENCES markets(id),
    target_price DECIMAL(10, 2), -- Alert triggers when price hits this
    notify_on_spike BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, crop_id)
);

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    crop_id UUID REFERENCES crops(id),
    alert_type VARCHAR(50), -- 'PRICE_DROP', 'PRICE_SPIKE', 'TARGET_HIT'
    message_en TEXT,
    message_ta TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200),
    body TEXT,
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, SENT, FAILED
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Admin Logs
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES users(id),
    action VARCHAR(100),
    target_table VARCHAR(50),
    target_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sample Seed Data for AgriPrice AI

-- Insert Users
INSERT INTO users (id, phone_number, full_name, preferred_language, role, is_verified) 
VALUES 
('d1111111-1111-1111-1111-111111111111', '+919876543210', 'Kumar', 'ta', 'FARMER', true),
('d2222222-2222-2222-2222-222222222222', '+918765432109', 'Admin', 'en', 'ADMIN', true);

-- Insert Crops
INSERT INTO crops (id, name_en, name_ta, category, base_shelf_life_days)
VALUES
('c1111111-1111-1111-1111-111111111111', 'Tomato', 'தக்காளி (Thakkali)', 'Vegetable', 7),
('c2222222-2222-2222-2222-222222222222', 'Onion', 'வெங்காயம் (Vengayam)', 'Vegetable', 45),
('c3333333-3333-3333-3333-333333333333', 'Paddy', 'நெல் (Nel)', 'Grain', 365);

-- Insert Markets with Approximate Geolocation points (Longitude, Latitude)
-- Point ordering is (Longitude, Latitude) in PostGIS
INSERT INTO markets (id, name_en, name_ta, district, location)
VALUES
('m1111111-1111-1111-1111-111111111111', 'Koyambedu Market', 'கோயம்பேடு சந்தை', 'Chennai', ST_SetSRID(ST_MakePoint(80.1913, 13.0674), 4326)),
('m2222222-2222-2222-2222-222222222222', 'Oddanchatram Market', 'ஒட்டன்சத்திரம் சந்தை', 'Dindigul', ST_SetSRID(ST_MakePoint(77.7469, 10.5186), 4326));

-- Insert Crop Prices (Historical data for Tomato at Koyambedu)
INSERT INTO crop_prices (crop_id, market_id, price_per_kg, record_date)
VALUES
('c1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 30.00, CURRENT_DATE - INTERVAL '3 days'),
('c1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 32.50, CURRENT_DATE - INTERVAL '2 days'),
('c1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 40.00, CURRENT_DATE - INTERVAL '1 day'),
('c1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 45.00, CURRENT_DATE);

-- Insert Sample Recommendation
INSERT INTO recommendations (crop_id, market_id, action, reasoning_en, reasoning_ta)
VALUES
('c1111111-1111-1111-1111-111111111111', 'm1111111-1111-1111-1111-111111111111', 'SELL', 'Prices have spiked due to local festival demand. Expected to drop soon.', 'உள்ளூர் திருவிழா தேவையால் விலைகள் உயர்ந்துள்ளன. விரைவில் குறைய வாய்ப்புள்ளது.');

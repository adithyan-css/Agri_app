-- Seed Tamil Nadu Uzhavar Sandhai markets with real GPS coordinates and prices
-- Source: APMC market data from screenshots

BEGIN;

-- ============================================================
-- 1. INSERT MARKETS with real GPS coordinates
-- ============================================================

INSERT INTO markets (id, name_en, name_ta, district, state, is_active, location)
VALUES
  -- Ariyalur
  ('a0000001-0001-4000-8000-000000000001', 'Ariyalur(Uzhavar Sandhai) APMC', 'அரியலூர்(உழவர் சந்தை) APMC', 'Ariyalur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.0786, 11.1382), 4326)),
  -- Coimbatore - Kurichi
  ('a0000001-0002-4000-8000-000000000002', 'Kurichi(Uzhavar Sandhai) APMC', 'குறிச்சி(உழவர் சந்தை) APMC', 'Coimbatore', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(76.9680, 10.9631), 4326)),
  -- Coimbatore - Mettupalayam
  ('a0000001-0003-4000-8000-000000000003', 'Mettupalayam(Uzhavar Sandhai) APMC', 'மேட்டுப்பாளையம்(உழவர் சந்தை) APMC', 'Coimbatore', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(76.9419, 11.2990), 4326)),
  -- Coimbatore - Singanallur
  ('a0000001-0004-4000-8000-000000000004', 'Singanallur(Uzhavar Sandhai) APMC', 'சிங்கநல்லூர்(உழவர் சந்தை) APMC', 'Coimbatore', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(76.9674, 11.0032), 4326)),
  -- Cuddalore - Panruti
  ('a0000001-0005-4000-8000-000000000005', 'Panruti(Uzhavar Sandhai) APMC', 'பண்ருட்டி(உழவர் சந்தை) APMC', 'Cuddalore', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.5527, 11.7744), 4326)),
  -- Dharmapuri - Palacode
  ('a0000001-0006-4000-8000-000000000006', 'Palacode(Uzhavar Sandhai) APMC', 'பாலக்கோடு(உழவர் சந்தை) APMC', 'Dharmapuri', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.9080, 12.1525), 4326)),
  -- Erode - Gobichettipalayam
  ('a0000001-0007-4000-8000-000000000007', 'Gobichettipalayam(Uzhavar Sandhai) APMC', 'கோபிசெட்டிபாளையம்(உழவர் சந்தை) APMC', 'Erode', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.4360, 11.4540), 4326)),
  -- Kallakuruchi
  ('a0000001-0008-4000-8000-000000000008', 'Kallakurichi(Uzhavar Sandhai) APMC', 'கள்ளக்குறிச்சி(உழவர் சந்தை) APMC', 'Kallakuruchi', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.9615, 11.7378), 4326)),
  -- Kancheepuram - Kundrathur
  ('a0000001-0009-4000-8000-000000000009', 'Kundrathur(Uzhavar Sandhai) APMC', 'குன்றத்தூர்(உழவர் சந்தை) APMC', 'Kancheepuram', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(80.0714, 12.9978), 4326)),
  -- Karur - Gandhigramam
  ('a0000001-0010-4000-8000-000000000010', 'Gandhigramam(Uzhavar Sandhai)', 'காந்தி கிராமம்(உழவர் சந்தை)', 'Karur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.0760, 10.9600), 4326)),
  -- Karur - Velayuthampalayam
  ('a0000001-0011-4000-8000-000000000011', 'Velayuthampalayam(Uzhavar Sandhai) APMC', 'வேலாயுதம்பாளையம்(உழவர் சந்தை) APMC', 'Karur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.0830, 10.9570), 4326)),
  -- Krishnagiri - Avallapalli
  ('a0000001-0012-4000-8000-000000000012', 'Avallapalli(Uzhavar Sandhai) APMC', 'அவல்லாபள்ளி(உழவர் சந்தை) APMC', 'Krishnagiri', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.2135, 12.5267), 4326)),
  -- Nagapattinam - Mayiladuthurai
  ('a0000001-0013-4000-8000-000000000013', 'Mayiladuthurai(Uzhavar Sandhai) APMC', 'மயிலாடுதுறை(உழவர் சந்தை) APMC', 'Nagapattinam', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.6499, 11.1019), 4326)),
  -- Nagercoil - Vadaseri
  ('a0000001-0014-4000-8000-000000000014', 'Nagercoil (Kannyiakumari), Vadaseri APMC', 'நாகர்கோவில்(கன்னியாகுமரி) வடசேரி APMC', 'Kannyiakumari', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.4115, 8.1804), 4326)),
  -- Namakkal - Mohanur
  ('a0000001-0015-4000-8000-000000000015', 'Mohanur(Uzhavar Sandhai) APMC', 'மோகனூர்(உழவர் சந்தை) APMC', 'Namakkal', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.1274, 11.0582), 4326)),
  -- Namakkal - Rasipuram
  ('a0000001-0016-4000-8000-000000000016', 'Rasipuram(Uzhavar Sandhai) APMC', 'ராசிபுரம்(உழவர் சந்தை) APMC', 'Namakkal', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.1807, 11.4647), 4326)),
  -- Pudukkottai - Alangudi
  ('a0000001-0017-4000-8000-000000000017', 'Alangudi(Uzhavar Sandhai) APMC', 'ஆலங்குடி(உழவர் சந்தை) APMC', 'Pudukkottai', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.1850, 10.3670), 4326)),
  -- Pudukkottai - Karambakkudi
  ('a0000001-0018-4000-8000-000000000018', 'Karambakkudi(Uzhavar Sandhai) APMC', 'கரம்பக்குடி(உழவர் சந்தை) APMC', 'Pudukkottai', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.2054, 10.3578), 4326)),
  -- Ramanathapuram
  ('a0000001-0019-4000-8000-000000000019', 'Ramanathapuram(Uzhavar Sandhai) APMC', 'ராமநாதபுரம்(உழவர் சந்தை) APMC', 'Ramanathapuram', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.8395, 9.3639), 4326)),
  -- Salem - Hasthampatti
  ('a0000001-0020-4000-8000-000000000020', 'Hasthampatti(Uzhavar Sandhai) APMC', 'ஹஸ்தம்பட்டி(உழவர் சந்தை) APMC', 'Salem', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.1581, 11.6617), 4326)),
  -- Salem - Mecheri
  ('a0000001-0021-4000-8000-000000000021', 'Mecheri(Uzhavar Sandhai)', 'மேச்சேரி(உழவர் சந்தை)', 'Salem', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.9560, 11.8260), 4326)),
  -- Salem - Mettur
  ('a0000001-0022-4000-8000-000000000022', 'Mettur(Uzhavar Sandhai) APMC', 'மேட்டூர்(உழவர் சந்தை) APMC', 'Salem', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.8024, 11.7867), 4326)),
  -- Salem - Sooramangalam
  ('a0000001-0023-4000-8000-000000000023', 'Sooramangalam(Uzhavar Sandhai) APMC', 'சூரமங்கலம்(உழவர் சந்தை) APMC', 'Salem', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.1660, 11.6480), 4326)),
  -- Salem - Vazhapadi
  ('a0000001-0024-4000-8000-000000000024', 'Vazhapadi(Uzhavar Sandhai)', 'வாழப்பாடி(உழவர் சந்தை)', 'Salem', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.4000, 11.6610), 4326)),
  -- Sivaganga - Devakottai
  ('a0000001-0025-4000-8000-000000000025', 'Devakottai(Uzhavar Sandhai) APMC', 'தேவகோட்டை(உழவர் சந்தை) APMC', 'Sivaganga', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.8183, 10.1538), 4326)),
  -- Sivaganga - Karaikudi
  ('a0000001-0026-4000-8000-000000000026', 'Karaikudi(Uzhavar Sandhai) APMC', 'காரைக்குடி(உழவர் சந்தை) APMC', 'Sivaganga', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.7758, 10.0733), 4326)),
  -- Thanjavur - Kumbakonam
  ('a0000001-0027-4000-8000-000000000027', 'Kumbakonam(Uzhavar Sandhai) APMC', 'கும்பகோணம்(உழவர் சந்தை) APMC', 'Thanjavur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.3845, 10.9602), 4326)),
  -- The Nilgiris - Gudalur
  ('a0000001-0028-4000-8000-000000000028', 'Gudalur(Uzhavar Sandhai) APMC', 'குடலூர்(உழவர் சந்தை) APMC', 'The Nilgiris', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(76.4981, 11.5040), 4326)),
  -- Theni - Andipatti
  ('a0000001-0029-4000-8000-000000000029', 'Andipatti(Uzhavar Sandhai) APMC', 'ஆண்டிபட்டி(உழவர் சந்தை) APMC', 'Theni', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.6075, 9.9838), 4326)),
  -- Theni - Chinnamanur
  ('a0000001-0030-4000-8000-000000000030', 'Chinnamanur(Uzhavar Sandhai) APMC', 'சின்னமனூர்(உழவர் சந்தை) APMC', 'Theni', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.3861, 9.8358), 4326)),
  -- Theni - Periyakulam
  ('a0000001-0031-4000-8000-000000000031', 'Periyakulam(Uzhavar Sandhai) APMC', 'பெரியகுளம்(உழவர் சந்தை) APMC', 'Theni', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.5471, 10.1227), 4326)),
  -- Thiruchirappalli - Thuraiyur
  ('a0000001-0032-4000-8000-000000000032', 'Thuraiyur APMC', 'துறையூர் APMC', 'Thiruchirappalli', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(78.5926, 11.0976), 4326)),
  -- Thirupur - Kangayam
  ('a0000001-0033-4000-8000-000000000033', 'Kangayam(Uzhavar Sandhai) APMC', 'காங்கேயம்(உழவர் சந்தை) APMC', 'Thirupur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.5632, 10.5640), 4326)),
  -- Thiruvannamalai - Cheyyar
  ('a0000001-0034-4000-8000-000000000034', 'Cheyyar(Uzhavar Sandhai) APMC', 'செய்யாறு(உழவர் சந்தை) APMC', 'Thiruvannamalai', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.5423, 12.6613), 4326)),
  -- Thiruvannamalai - Tiruvannamalai
  ('a0000001-0035-4000-8000-000000000035', 'Tiruvannamalai(Uzhavar Sandhai) APMC', 'திருவண்ணாமலை(உழவர் சந்தை) APMC', 'Thiruvannamalai', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.0747, 12.2253), 4326)),
  -- Thiruvarur - Tiruvarur
  ('a0000001-0036-4000-8000-000000000036', 'Tiruvarur(Uzhavar Sandhai) APMC', 'திருவாரூர்(உழவர் சந்தை) APMC', 'Thiruvarur', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.6367, 10.7679), 4326)),
  -- Vellore - Katpadi
  ('a0000001-0037-4000-8000-000000000037', 'Katpadi(Uzhavar Sandhai) APMC', 'காட்பாடி(உழவர் சந்தை) APMC', 'Vellore', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(79.1506, 12.9737), 4326)),
  -- Virudhunagar - Sivakasi
  ('a0000001-0038-4000-8000-000000000038', 'Sivakasi(Uzhavar Sandhai) APMC', 'சிவகாசி(உழவர் சந்தை) APMC', 'Virudhunagar', 'Tamil Nadu', true, ST_SetSRID(ST_MakePoint(77.7997, 9.4534), 4326))
ON CONFLICT (id) DO UPDATE SET
  name_en = EXCLUDED.name_en,
  name_ta = EXCLUDED.name_ta,
  district = EXCLUDED.district,
  state = EXCLUDED.state,
  is_active = EXCLUDED.is_active,
  location = EXCLUDED.location;

-- Also update the existing TN markets that have generic (11,77) coordinates
-- Coimbatore Market
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(76.9558, 11.0168), 4326)
  WHERE name_en = 'Coimbatore Market' AND state = 'Tamil Nadu';
-- Erode Market
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(77.7172, 11.3410), 4326)
  WHERE name_en = 'Erode Market' AND state = 'Tamil Nadu';
-- Madurai Market
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(78.1198, 9.9252), 4326)
  WHERE name_en = 'Madurai Market' AND state = 'Tamil Nadu';
-- Salem Market
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(78.1460, 11.6643), 4326)
  WHERE name_en = 'Salem Market' AND state = 'Tamil Nadu';
-- Default Market (Chennai)
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(80.2707, 13.0827), 4326)
  WHERE name_en = 'Default Market' AND district = 'Chennai' AND state = 'Tamil Nadu';
-- Lalgudi
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(78.8143, 10.8735), 4326)
  WHERE name_en = 'Lalgudi(Uzhavar Sandhai )' AND state = 'Tamil Nadu';
-- Manachanallur
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(78.8184, 10.8937), 4326)
  WHERE name_en = 'Manachanallur(Uzhavar Sandhai )' AND state = 'Tamil Nadu';
-- Manapparai
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(78.4213, 10.6098), 4326)
  WHERE name_en = 'Manapparai(Uzhavar Sandhai )' AND state = 'Tamil Nadu';
-- Tamarainagar
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(79.0747, 12.2253), 4326)
  WHERE name_en = 'Tamarainagar(Uzhavar Sandhai )' AND state = 'Tamil Nadu';
-- thiruvannamalai Market
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(79.0747, 12.2253), 4326)
  WHERE name_en = 'thiruvannamalai Market' AND state = 'Tamil Nadu';
-- Arcot
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(79.3164, 12.9048), 4326)
  WHERE name_en = 'Arcot(Uzhavar Sandhai )' AND state = 'Tamil Nadu';
-- Ranipettai
UPDATE markets SET location = ST_SetSRID(ST_MakePoint(79.3342, 12.9328), 4326)
  WHERE name_en LIKE '%anipet%' AND state = 'Tamil Nadu';


-- ============================================================
-- 2. INSERT CROP PRICES from screenshot data
--    Using first Onion crop ID: 3da879a3-f1c4-4d1a-b573-87d8057874c7
--    Record date: 2026-03-05 (today)
-- ============================================================

-- We'll use the avg_rate from the screenshots as price_per_kg
INSERT INTO crop_prices (id, crop_id, market_id, price_per_kg, record_date, quality_grade) VALUES
  -- Ariyalur: min=20, max=24, avg=22
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0001-4000-8000-000000000001', 22.00, '2026-03-05', 'A'),
  -- Coimbatore Kurichi: min=20, max=24, avg=22
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0002-4000-8000-000000000002', 22.00, '2026-03-05', 'A'),
  -- Coimbatore Mettupalayam: min=20, max=24, avg=22
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0003-4000-8000-000000000003', 22.00, '2026-03-05', 'A'),
  -- Coimbatore Singanallur: min=18, max=21, avg=19.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0004-4000-8000-000000000004', 19.50, '2026-03-05', 'A'),
  -- Cuddalore Panruti: min=25, max=25, avg=25
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0005-4000-8000-000000000005', 25.00, '2026-03-05', 'A'),
  -- Dharmapuri Palacode: min=23, max=25, avg=24
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0006-4000-8000-000000000006', 24.00, '2026-03-05', 'A'),
  -- Erode Gobichettipalayam: min=30, max=35, avg=32.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0007-4000-8000-000000000007', 32.50, '2026-03-05', 'A'),
  -- Kallakuruchi: min=30, max=30, avg=30
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0008-4000-8000-000000000008', 30.00, '2026-03-05', 'A'),
  -- Kancheepuram Kundrathur: min=25, max=25, avg=25
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0009-4000-8000-000000000009', 25.00, '2026-03-05', 'A'),
  -- Karur Gandhigramam: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0010-4000-8000-000000000010', 27.50, '2026-03-05', 'A'),
  -- Karur Velayuthampalayam: min=24, max=30, avg=27
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0011-4000-8000-000000000011', 27.00, '2026-03-05', 'A'),
  -- Krishnagiri Avallapalli: min=20, max=25, avg=22.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0012-4000-8000-000000000012', 22.50, '2026-03-05', 'A'),
  -- Nagapattinam Mayiladuthurai: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0013-4000-8000-000000000013', 27.50, '2026-03-05', 'A'),
  -- Nagercoil Vadaseri: min=30, max=35, avg=32.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0014-4000-8000-000000000014', 32.50, '2026-03-05', 'A'),
  -- Namakkal Mohanur: min=24, max=30, avg=27
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0015-4000-8000-000000000015', 27.00, '2026-03-05', 'A'),
  -- Namakkal Rasipuram: min=30, max=34, avg=32
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0016-4000-8000-000000000016', 32.00, '2026-03-05', 'A'),
  -- Pudukkottai Alangudi: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0017-4000-8000-000000000017', 27.50, '2026-03-05', 'A'),
  -- Pudukkottai Karambakkudi: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0018-4000-8000-000000000018', 27.50, '2026-03-05', 'A'),
  -- Ramanathapuram: min=25, max=28, avg=26.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0019-4000-8000-000000000019', 26.50, '2026-03-05', 'A'),
  -- Salem Hasthampatti: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0020-4000-8000-000000000020', 27.50, '2026-03-05', 'A'),
  -- Salem Mecheri: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0021-4000-8000-000000000021', 27.50, '2026-03-05', 'A'),
  -- Salem Mettur: min=24, max=28, avg=26
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0022-4000-8000-000000000022', 26.00, '2026-03-05', 'A'),
  -- Salem Sooramangalam: min=26, max=30, avg=28
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0023-4000-8000-000000000023', 28.00, '2026-03-05', 'A'),
  -- Salem Vazhapadi: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0024-4000-8000-000000000024', 27.50, '2026-03-05', 'A'),
  -- Sivaganga Devakottai: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0025-4000-8000-000000000025', 27.50, '2026-03-05', 'A'),
  -- Sivaganga Karaikudi: min=28, max=32, avg=30
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0026-4000-8000-000000000026', 30.00, '2026-03-05', 'A'),
  -- Thanjavur Kumbakonam: min=24, max=30, avg=27
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0027-4000-8000-000000000027', 27.00, '2026-03-05', 'A'),
  -- The Nilgiris Gudalur: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0028-4000-8000-000000000028', 27.50, '2026-03-05', 'A'),
  -- Theni Andipatti: min=22, max=25, avg=23.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0029-4000-8000-000000000029', 23.50, '2026-03-05', 'A'),
  -- Theni Chinnamanur: min=25, max=26, avg=25.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0030-4000-8000-000000000030', 25.50, '2026-03-05', 'A'),
  -- Theni Periyakulam: min=24, max=25, avg=24.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0031-4000-8000-000000000031', 24.50, '2026-03-05', 'A'),
  -- Thiruchirappalli Thuraiyur: min=25, max=28, avg=26.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0032-4000-8000-000000000032', 26.50, '2026-03-05', 'A'),
  -- Thirupur Kangayam: min=25, max=30, avg=27.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0033-4000-8000-000000000033', 27.50, '2026-03-05', 'A'),
  -- Thiruvannamalai Cheyyar: min=20, max=25, avg=22.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0034-4000-8000-000000000034', 22.50, '2026-03-05', 'A'),
  -- Thiruvannamalai: min=20, max=25, avg=22.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0035-4000-8000-000000000035', 22.50, '2026-03-05', 'A'),
  -- Thiruvarur Tiruvarur: min=36, max=36, avg=36
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0036-4000-8000-000000000036', 36.00, '2026-03-05', 'A'),
  -- Vellore Katpadi: min=25, max=25, avg=25
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0037-4000-8000-000000000037', 25.00, '2026-03-05', 'A'),
  -- Virudhunagar Sivakasi: min=22, max=25, avg=23.5
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0038-4000-8000-000000000038', 23.50, '2026-03-05', 'A');

-- Also insert min and max price records as different quality grades
INSERT INTO crop_prices (id, crop_id, market_id, price_per_kg, record_date, quality_grade) VALUES
  -- Min prices (quality grade B)
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0001-4000-8000-000000000001', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0002-4000-8000-000000000002', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0003-4000-8000-000000000003', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0004-4000-8000-000000000004', 18.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0005-4000-8000-000000000005', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0006-4000-8000-000000000006', 23.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0007-4000-8000-000000000007', 30.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0008-4000-8000-000000000008', 30.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0009-4000-8000-000000000009', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0010-4000-8000-000000000010', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0011-4000-8000-000000000011', 24.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0012-4000-8000-000000000012', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0013-4000-8000-000000000013', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0014-4000-8000-000000000014', 30.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0015-4000-8000-000000000015', 24.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0016-4000-8000-000000000016', 30.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0017-4000-8000-000000000017', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0018-4000-8000-000000000018', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0019-4000-8000-000000000019', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0020-4000-8000-000000000020', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0021-4000-8000-000000000021', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0022-4000-8000-000000000022', 24.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0023-4000-8000-000000000023', 26.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0024-4000-8000-000000000024', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0025-4000-8000-000000000025', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0026-4000-8000-000000000026', 28.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0027-4000-8000-000000000027', 24.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0028-4000-8000-000000000028', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0029-4000-8000-000000000029', 22.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0030-4000-8000-000000000030', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0031-4000-8000-000000000031', 24.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0032-4000-8000-000000000032', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0033-4000-8000-000000000033', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0034-4000-8000-000000000034', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0035-4000-8000-000000000035', 20.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0036-4000-8000-000000000036', 36.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0037-4000-8000-000000000037', 25.00, '2026-03-05', 'B'),
  (uuid_generate_v4(), '3da879a3-f1c4-4d1a-b573-87d8057874c7', 'a0000001-0038-4000-8000-000000000038', 22.00, '2026-03-05', 'B');

COMMIT;

import * as fs from 'fs';
import * as path from 'path';
import * as csvParser from 'csv-parser';
import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config({ path: path.resolve(__dirname, '../../../.env') });

const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'user',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_DATABASE || 'agriprice',
  synchronize: false,
  logging: false,
});

function readCsv<T>(filePath: string): Promise<T[]> {
  return new Promise((resolve, reject) => {
    const rows: T[] = [];
    fs.createReadStream(filePath)
      .pipe(csvParser())
      .on('data', (row: T) => rows.push(row))
      .on('end', () => resolve(rows))
      .on('error', reject);
  });
}

async function seed() {
  console.log('Connecting to database...');
  await dataSource.initialize();
  const qr = dataSource.createQueryRunner();
  await qr.connect();

  try {
    // ── Prepare: drop old tables so they get recreated with text PKs ──
    console.log('Preparing tables...');
    await qr.query(`DROP TABLE IF EXISTS crop_prices CASCADE`);
    await qr.query(`DROP TABLE IF EXISTS crops CASCADE`);
    await qr.query(`DROP TABLE IF EXISTS markets CASCADE`);

    // Recreate tables with text PK types
    await qr.query(`
      CREATE TABLE IF NOT EXISTS crops (
        id TEXT PRIMARY KEY,
        name_en VARCHAR NOT NULL,
        name_ta VARCHAR NOT NULL,
        category VARCHAR,
        unit VARCHAR(50),
        image_url TEXT,
        base_shelf_life_days INTEGER,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);
    await qr.query(`
      CREATE TABLE IF NOT EXISTS markets (
        id TEXT PRIMARY KEY,
        name_en VARCHAR NOT NULL,
        name_ta VARCHAR NOT NULL,
        district VARCHAR NOT NULL,
        state VARCHAR NOT NULL,
        location geometry(Point, 4326),
        phone VARCHAR(50),
        open_hours VARCHAR(50),
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);
    await qr.query(`
      CREATE TABLE IF NOT EXISTS crop_prices (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        market_id TEXT NOT NULL,
        record_date DATE NOT NULL,
        price_per_kg DECIMAL(10,2),
        min_price DECIMAL(10,2),
        max_price DECIMAL(10,2),
        modal_price DECIMAL(10,2),
        arrival_qty INTEGER,
        source VARCHAR(100),
        quality_grade VARCHAR(10) DEFAULT 'A',
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('Tables ready.');


    // ────── CROPS ──────
    const cropsFile = path.join(__dirname, 'crops.csv');
    const crops = await readCsv<any>(cropsFile);
    console.log(`Read ${crops.length} crops from CSV`);

    for (const c of crops) {
      await qr.query(
        `INSERT INTO crops (id, name_en, name_ta, category, unit, image_url, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT (id) DO UPDATE SET
           name_en = EXCLUDED.name_en,
           name_ta = EXCLUDED.name_ta,
           category = EXCLUDED.category,
           unit = EXCLUDED.unit,
           image_url = EXCLUDED.image_url`,
        [
          c.id,
          c.name,
          c.tamil_name,
          c.category,
          c.unit || 'kg',
          c.image_url || null,
          c.created_at || new Date().toISOString(),
        ],
      );
    }
    console.log(`Seeded ${crops.length} crops`);

    // ────── MARKETS ──────
    const marketsFile = path.join(__dirname, 'markets.csv');
    const markets = await readCsv<any>(marketsFile);
    console.log(`Read ${markets.length} markets from CSV`);

    for (const m of markets) {
      const lat = parseFloat(m.latitude);
      const lng = parseFloat(m.longitude);
      const isActive = m.is_open === 'true' || m.is_open === true;

      await qr.query(
        `INSERT INTO markets (id, name_en, name_ta, district, state, location, phone, open_hours, is_active, created_at)
         VALUES ($1, $2, $3, $4, $5, ST_SetSRID(ST_MakePoint($6, $7), 4326), $8, $9, $10, $11)
         ON CONFLICT (id) DO UPDATE SET
           name_en = EXCLUDED.name_en,
           name_ta = EXCLUDED.name_ta,
           district = EXCLUDED.district,
           state = EXCLUDED.state,
           location = EXCLUDED.location,
           phone = EXCLUDED.phone,
           open_hours = EXCLUDED.open_hours,
           is_active = EXCLUDED.is_active`,
        [
          m.id,
          m.name,
          m.name, // name_ta = same as name for now (no Tamil name in CSV)
          m.district,
          m.state,
          lng, // ST_MakePoint(lng, lat)
          lat,
          m.phone || null,
          m.open_hours || null,
          isActive,
          m.created_at || new Date().toISOString(),
        ],
      );
    }
    console.log(`Seeded ${markets.length} markets`);

    // ────── CROP_PRICES ──────
    const pricesFile = path.join(__dirname, 'crop_prices.csv');
    const prices = await readCsv<any>(pricesFile);
    console.log(`Read ${prices.length} crop prices from CSV`);

    // Batch insert prices in chunks to avoid memory issues
    const BATCH = 500;
    for (let i = 0; i < prices.length; i += BATCH) {
      const batch = prices.slice(i, i + BATCH);
      const values: any[] = [];
      const placeholders: string[] = [];
      let idx = 1;

      for (const p of batch) {
        const modalPrice = parseFloat(p.modal_price) || 0;
        placeholders.push(
          `($${idx}, $${idx + 1}, $${idx + 2}, $${idx + 3}, $${idx + 4}, $${idx + 5}, $${idx + 6}, $${idx + 7}, $${idx + 8}, $${idx + 9})`,
        );
        values.push(
          p.id,
          p.crop_id,
          p.market_id,
          p.date,
          modalPrice,              // price_per_kg = modal_price
          parseFloat(p.min_price) || null,
          parseFloat(p.max_price) || null,
          modalPrice || null,      // modal_price
          parseInt(p.arrival_qty, 10) || null,
          p.source || null,
        );
        idx += 10;
      }

      await qr.query(
        `INSERT INTO crop_prices (id, crop_id, market_id, record_date, price_per_kg, min_price, max_price, modal_price, arrival_qty, source)
         VALUES ${placeholders.join(', ')}
         ON CONFLICT (id) DO UPDATE SET
           price_per_kg = EXCLUDED.price_per_kg,
           min_price = EXCLUDED.min_price,
           max_price = EXCLUDED.max_price,
           modal_price = EXCLUDED.modal_price,
           arrival_qty = EXCLUDED.arrival_qty,
           source = EXCLUDED.source`,
        values,
      );

      process.stdout.write(`\r  Prices: ${Math.min(i + BATCH, prices.length)}/${prices.length}`);
    }
    console.log('\nSeeded all crop prices');

    console.log('\n✔ Seed complete!');
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  } finally {
    await qr.release();
    await dataSource.destroy();
  }
}

seed();

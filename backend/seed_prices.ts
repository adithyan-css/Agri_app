/**
 * seed_prices.ts — Robust CSV-to-PostgreSQL seeding pipeline for AgriPrice AI
 *
 * Reads  : backend/data/agriculture_prices.csv   (737 k rows)
 * Writes : crops, markets, crop_prices tables
 *
 * Run    : npx ts-node seed_prices.ts
 */

import * as fs from "fs";
import { Client } from "pg";
const csv = require("csv-parser");

// ──────────────────────────────────────────────────────────────
// 1. Configuration
// ──────────────────────────────────────────────────────────────
const DB_CONFIG = {
  host: "localhost",
  port: 5432,
  user: "user",
  password: "password",
  database: "agriprice",
};

const BATCH_SIZE = 1000;
const LOG_EVERY = 10_000;

/** Commodity → fixed crop UUID (as specified by the project) */
const CROP_MAP: Record<string, { id: string; name_ta: string; category: string }> = {
  Tomato: { id: "b7d9d4e7-7d1a-42a2-ab13-da80f67cbadd", name_ta: "தக்காளி (Thakkali)", category: "Vegetable" },
  Onion:  { id: "447d2dff-c3a9-4e45-9d9b-a30df8a50022", name_ta: "வெங்காயம் (Vengayam)", category: "Vegetable" },
  Potato: { id: "794f9dee-3264-45a2-a2e5-9f22b0812240", name_ta: "உருளைக்கிழங்கு (Urulaikizhangu)", category: "Vegetable" },
  Rice:   { id: "86ba18a1-37ba-45af-9e0d-3bcaf1bb6cd6", name_ta: "அரிசி (Arisi)", category: "Grain" },
  Wheat:  { id: "ecf98715-6f97-4f29-a013-47cb07b8886c", name_ta: "கோதுமை (Kothumai)", category: "Grain" },
};

// ──────────────────────────────────────────────────────────────
// 2. Helpers
// ──────────────────────────────────────────────────────────────

/** Parse "M/D/YYYY" → "YYYY-MM-DD" (returns null on failure) */
function parseDate(raw: string | undefined): string | null {
  if (!raw || !raw.trim()) return null;
  const parts = raw.trim().split("/");
  if (parts.length !== 3) return null;
  const [m, d, y] = parts;
  const mm = m.padStart(2, "0");
  const dd = d.padStart(2, "0");
  // basic sanity
  if (+y < 1900 || +mm > 12 || +dd > 31) return null;
  return `${y}-${mm}-${dd}`;
}

/** Pretty elapsed time */
function elapsed(start: number): string {
  const s = ((Date.now() - start) / 1000).toFixed(1);
  return `${s}s`;
}

// ──────────────────────────────────────────────────────────────
// 3. Main pipeline
// ──────────────────────────────────────────────────────────────
async function seed() {
  const t0 = Date.now();
  const client = new Client(DB_CONFIG);
  await client.connect();
  console.log("✓ Connected to PostgreSQL\n");

  // ── 3a. Upsert crops with the specified UUIDs ────────────
  console.log("── Upserting crops ──");
  for (const [nameEn, meta] of Object.entries(CROP_MAP)) {
    await client.query(
      `INSERT INTO crops (id, name_en, name_ta, category)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (id) DO UPDATE SET name_en = EXCLUDED.name_en`,
      [meta.id, nameEn, meta.name_ta, meta.category],
    );
    console.log(`  ${nameEn} → ${meta.id}`);
  }

  // ── 3b. Read CSV into memory ─────────────────────────────
  console.log("\n── Reading CSV ──");
  const rows: Record<string, string>[] = await new Promise((resolve, reject) => {
    const buf: Record<string, string>[] = [];
    fs.createReadStream("data/agriculture_prices.csv")
      .pipe(csv())
      .on("data", (row: Record<string, string>) => buf.push(row))
      .on("end", () => resolve(buf))
      .on("error", reject);
  });
  console.log(`  Total rows in CSV: ${rows.length.toLocaleString()}`);

  // ── 3c. Discover & insert unique markets from CSV ────────
  console.log("\n── Discovering markets ──");
  // Build map: "State|District|Market" → { state, district, name }
  const marketKey = (r: Record<string, string>) =>
    `${r["STATE"]?.trim()}|${r["District Name"]?.trim()}|${r["Market Name"]?.trim()}`;

  const uniqueMarkets = new Map<string, { state: string; district: string; name: string }>();
  for (const r of rows) {
    const key = marketKey(r);
    if (!uniqueMarkets.has(key)) {
      uniqueMarkets.set(key, {
        state: r["STATE"]?.trim() || "Unknown",
        district: r["District Name"]?.trim() || "Unknown",
        name: r["Market Name"]?.trim() || "Unknown",
      });
    }
  }
  console.log(`  Unique markets found: ${uniqueMarkets.size}`);

  // Insert markets in batches and build name→uuid lookup
  // Use a dummy point (0,0) since CSV has no geo data; location is NOT NULL in schema.
  const marketIdMap = new Map<string, string>(); // compositeKey → uuid

  const marketEntries = [...uniqueMarkets.entries()];
  for (let i = 0; i < marketEntries.length; i += BATCH_SIZE) {
    const batch = marketEntries.slice(i, i + BATCH_SIZE);
    for (const [key, m] of batch) {
      const res = await client.query(
        `INSERT INTO markets (name_en, name_ta, district, state, location)
         VALUES ($1, $1, $2, $3, ST_SetSRID(ST_MakePoint(0, 0), 4326))
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [m.name, m.district, m.state],
      );
      if (res.rows.length > 0) {
        marketIdMap.set(key, res.rows[0].id);
      } else {
        // already exists – look it up
        const existing = await client.query(
          `SELECT id FROM markets WHERE name_en = $1 AND district = $2 AND state = $3 LIMIT 1`,
          [m.name, m.district, m.state],
        );
        if (existing.rows.length > 0) {
          marketIdMap.set(key, existing.rows[0].id);
        }
      }
    }
  }
  console.log(`  Markets in DB: ${marketIdMap.size}`);

  // ── 3d. Clear old price data for a clean seed ────────────
  console.log("\n── Clearing existing crop_prices ──");
  const delResult = await client.query(`DELETE FROM crop_prices`);
  console.log(`  Deleted ${delResult.rowCount} old rows`);

  // ── 3e. Batch-insert crop prices ─────────────────────────
  console.log("\n── Inserting crop prices ──");
  let inserted = 0;
  let skipped = 0;

  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE);
    const values: any[] = [];
    const placeholders: string[] = [];

    for (const row of batch) {
      // ─ crop_id
      const commodity = row["Commodity"]?.trim();
      const cropMeta = commodity ? CROP_MAP[commodity] : undefined;
      if (!cropMeta) { skipped++; continue; }

      // ─ market_id (uuid)
      const mKey = marketKey(row);
      const mId = marketIdMap.get(mKey);
      if (!mId) { skipped++; continue; }

      // ─ price
      const price = parseFloat(row["Modal_Price"]);
      if (isNaN(price) || price <= 0) { skipped++; continue; }

      // ─ date
      const recordDate = parseDate(row["Price Date"]);
      if (!recordDate) { skipped++; continue; }

      // ─ quality grade
      const grade = row["Grade"]?.trim() || "A";

      const idx = values.length;
      values.push(cropMeta.id, mId, price, recordDate, grade);
      placeholders.push(
        `($${idx + 1}, $${idx + 2}, $${idx + 3}, $${idx + 4}, $${idx + 5})`,
      );
    }

    if (placeholders.length > 0) {
      await client.query(
        `INSERT INTO crop_prices (crop_id, market_id, price_per_kg, record_date, quality_grade)
         VALUES ${placeholders.join(", ")}
         ON CONFLICT DO NOTHING`,
        values,
      );
      inserted += placeholders.length;
    }

    // progress log
    const processed = i + batch.length;
    if (processed % LOG_EVERY < BATCH_SIZE || processed >= rows.length) {
      const pct = ((processed / rows.length) * 100).toFixed(1);
      console.log(
        `  [${elapsed(t0)}] ${processed.toLocaleString()} / ${rows.length.toLocaleString()} ` +
        `(${pct}%) — inserted: ${inserted.toLocaleString()}, skipped: ${skipped.toLocaleString()}`,
      );
    }
  }

  // ── 3f. Summary ──────────────────────────────────────────
  const totalPrices = await client.query(`SELECT COUNT(*) AS cnt FROM crop_prices`);
  console.log(`\n══════════════════════════════════════`);
  console.log(`  Seed completed in ${elapsed(t0)}`);
  console.log(`  CSV rows      : ${rows.length.toLocaleString()}`);
  console.log(`  Inserted      : ${inserted.toLocaleString()}`);
  console.log(`  Skipped       : ${skipped.toLocaleString()}`);
  console.log(`  Total in DB   : ${Number(totalPrices.rows[0].cnt).toLocaleString()}`);
  console.log(`  Crops in DB   : ${Object.keys(CROP_MAP).length}`);
  console.log(`  Markets in DB : ${marketIdMap.size}`);
  console.log(`══════════════════════════════════════\n`);

  await client.end();
}

seed().catch((err) => {
  console.error("\n✗ Seed failed:", err.message || err);
  process.exit(1);
});
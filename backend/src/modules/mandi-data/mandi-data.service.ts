import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { Crop } from '../crops/entities/crop.entity';
import { CropPrice } from '../crops/entities/crop-price.entity';
import { Market } from '../markets/entities/market.entity';
import { v4 as uuidv4 } from 'uuid';

/**
 * Raw record shape returned by the data.gov.in commodity-prices API
 * (dataset 9ef84268-d588-465a-a308-a864a43d0070).
 */
interface MandiApiRecord {
    state: string;
    district: string;
    market: string;
    commodity: string;
    variety: string;
    arrival_date: string;   // "DD/MM/YYYY"
    min_price: string;      // per quintal
    max_price: string;
    modal_price: string;
}

interface MandiApiResponse {
    status: string;
    count: number;
    total: number;
    records: MandiApiRecord[];
}

/**
 * Commodity name mapping: data.gov.in commodity names → our seeded crop names.
 * The API returns commodity names that may differ from our naming; this map
 * normalises both sides to lowercase for matching.
 */
const COMMODITY_NAME_MAP: Record<string, string> = {
    'tomato': 'Tomato',
    'onion': 'Onion',
    'onion green': 'Onion',
    'potato': 'Potato',
    'paddy(dhan)(common)': 'Paddy',
    'paddy(dhan)': 'Paddy',
    'paddy(common)': 'Paddy',
    'paddy': 'Paddy',
    'rice': 'Paddy',
    'banana': 'Banana',
    'banana - green': 'Banana',
    'banana - loss': 'Banana',
    'carrot': 'Carrot',
    'brinjal': 'Brinjal',
    'green chilli': 'Green Chilli',
    'cabbage': 'Cabbage',
    'cauliflower': 'Cauliflower',
    'groundnut': 'Groundnut',
    'coconut': 'Coconut',
    'copra': 'Coconut',
    'coconut oil': 'Coconut',
    'tender coconut': 'Coconut',
    'turmeric': 'Turmeric',
    'turmeric(bulb)': 'Turmeric',
    'sugarcane': 'Sugarcane',
    'mango': 'Mango',
    'mango (raw-loss)': 'Mango',
    'mango(raw-ripe)': 'Mango',
    'beans': 'Beans',
    'french beans (frasbean)': 'Beans',
    'french beans(frasbean)': 'Beans',
    'indian beans(seam)': 'Beans',
    'garlic': 'Garlic',
    'ginger(dry)': 'Ginger',
    'ginger(green)': 'Ginger',
    'ginger': 'Ginger',
    'pumpkin': 'Pumpkin',
    'capsicum': 'Capsicum',
    'bhindi(ladies finger)': 'Ladies Finger',
    'ladies finger': 'Ladies Finger',
    'beetroot': 'Beetroot',
    'radish': 'Radish',
    'raddish': 'Radish',
    'coriander(leaves)': 'Coriander Leaves',
    'coriander': 'Coriander Leaves',
    'spinach': 'Spinach',
    'bitter gourd': 'Bitter Gourd',
    'bottle gourd': 'Bottle Gourd',
    'ridge gourd(tori)': 'Ridge Gourd',
    'ridgeguard(tori)': 'Ridge Gourd',
    'ridge gourd': 'Ridge Gourd',
    'snake gourd': 'Snake Gourd',
    'snakeguard': 'Snake Gourd',
    'drumstick': 'Drumstick',
    'lemon': 'Lemon',
    'lime': 'Lemon',
    'green peas': 'Green Peas',
    'tamarind fruit': 'Tamarind',
    'tamarind': 'Tamarind',
    'guava': 'Guava',
    'papaya': 'Papaya',
    'water melon': 'Watermelon',
    'watermelon': 'Watermelon',
    'pomegranate': 'Pomegranate',
    'pomogranate': 'Pomegranate',
    'grapes': 'Grapes',
    'apple': 'Apple',
    'orange': 'Orange',
    'chow chow': 'Chow Chow',
    'cluster beans': 'Cluster Beans',
    'sweet corn': 'Sweet Corn',
    'maize': 'Sweet Corn',
    'ash gourd': 'Ash Gourd',
    'ashgourd': 'Ash Gourd',
    'red chilli': 'Red Chilli Dry',
    'dry chillies': 'Red Chilli Dry',
    'black pepper': 'Black Pepper',
    'pepper': 'Black Pepper',
    'cardamom': 'Cardamom',
    'cardamom-loss': 'Cardamom',
    'cloves': 'Cloves',
    'cumin seed(jeera)': 'Cumin Seeds',
    'cuminseed(jeera)': 'Cumin Seeds',
    'curry leaf': 'Curry Leaves',
    'curry leaves': 'Curry Leaves',
};

@Injectable()
export class MandiDataService {
    private readonly logger = new Logger(MandiDataService.name);

    private readonly API_URL =
        'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070';
    private readonly STATE_FILTER = 'Tamil Nadu';

    /** In-memory caches populated once per app lifecycle (or on demand). */
    private cropNameMap: Map<string, Crop> | null = null;
    private marketDistrictMap: Map<string, Market> | null = null;
    private isIngesting = false;

    constructor(
        @InjectRepository(Crop)
        private readonly cropRepo: Repository<Crop>,
        @InjectRepository(CropPrice)
        private readonly cropPriceRepo: Repository<CropPrice>,
        @InjectRepository(Market)
        private readonly marketRepo: Repository<Market>,
        private readonly configService: ConfigService,
    ) {}

    // ─── Public: full ingestion cycle ────────────────────────────────

    async ingest(): Promise<{ inserted: number; updated: number; skipped: number; newMarkets: number }> {
        if (this.isIngesting) {
            this.logger.warn('Ingestion already in progress – skipping overlapping run');
            return { inserted: 0, updated: 0, skipped: 0, newMarkets: 0 };
        }

        const apiKey = this.configService.get<string>('DATA_GOV_API_KEY');
        if (!apiKey) {
            this.logger.warn('DATA_GOV_API_KEY not set – skipping mandi ingestion');
            return { inserted: 0, updated: 0, skipped: 0, newMarkets: 0 };
        }

        this.isIngesting = true;
        this.logger.log('Starting mandi data ingestion…');

        // Refresh the lookup caches
        await this.buildCropCache();
        await this.buildMarketCache();

        let offset = 0;
        const limit = 500;
        let totalInserted = 0;
        let totalUpdated = 0;
        let totalSkipped = 0;
        let totalNewMarkets = 0;
        let hasMore = true;

        while (hasMore) {
            const records = await this.fetchPage(apiKey, offset, limit);
            if (!records || records.length === 0) {
                hasMore = false;
                break;
            }

            const result = await this.processRecords(records);
            totalInserted += result.inserted;
            totalUpdated += result.updated;
            totalSkipped += result.skipped;
            totalNewMarkets += result.newMarkets;

            // If less than a full page, we've reached the end.
            if (records.length < limit) {
                hasMore = false;
            } else {
                offset += limit;
            }
        }

        this.isIngesting = false;
        this.logger.log(
            `Ingestion complete — inserted: ${totalInserted}, updated: ${totalUpdated}, ` +
            `skipped: ${totalSkipped}, new markets: ${totalNewMarkets}`,
        );
        return {
            inserted: totalInserted,
            updated: totalUpdated,
            skipped: totalSkipped,
            newMarkets: totalNewMarkets,
        };
    }

    // ─── API fetch ───────────────────────────────────────────────────

    private async fetchPage(apiKey: string, offset: number, limit: number): Promise<MandiApiRecord[]> {
        try {
            const params = new URLSearchParams({
                'api-key': apiKey,
                format: 'json',
                limit: String(limit),
                offset: String(offset),
                'filters[state]': this.STATE_FILTER,
            });

            const url = `${this.API_URL}?${params.toString()}`;
            const response = await axios.get<MandiApiResponse>(url, { timeout: 30_000 });
            return response.data?.records ?? [];
        } catch (err: any) {
            this.logger.error(`Failed to fetch page at offset=${offset}: ${err.message}`);
            return [];
        }
    }

    // ─── Processing ──────────────────────────────────────────────────

    private async processRecords(records: MandiApiRecord[]) {
        let inserted = 0;
        let updated = 0;
        let skipped = 0;
        let newMarkets = 0;

        for (const rec of records) {
            try {
                // 1. Resolve crop
                const crop = this.resolveCrop(rec.commodity);
                if (!crop) {
                    skipped++;
                    continue;
                }

                // 2. Resolve or create market
                const { market, isNew } = await this.resolveOrCreateMarket(rec);
                if (isNew) newMarkets++;

                // 3. Parse date (DD/MM/YYYY → YYYY-MM-DD)
                const recordDate = this.parseDate(rec.arrival_date);
                if (!recordDate) {
                    skipped++;
                    continue;
                }

                // 4. Convert quintal prices to per-kg
                const minPriceKg = this.quintalToKg(rec.min_price);
                const maxPriceKg = this.quintalToKg(rec.max_price);
                const modalPriceKg = this.quintalToKg(rec.modal_price);

                // 5. Upsert into crop_prices
                const wasUpdate = await this.upsertPrice({
                    cropId: crop.id,
                    marketId: market.id,
                    recordDate,
                    minPrice: minPriceKg,
                    maxPrice: maxPriceKg,
                    modalPrice: modalPriceKg,
                    pricePerKg: modalPriceKg,
                });

                if (wasUpdate) updated++;
                else inserted++;
            } catch (err: any) {
                this.logger.warn(`Record skipped: ${err.message}`);
                skipped++;
            }
        }

        return { inserted, updated, skipped, newMarkets };
    }

    // ─── Crop resolution ─────────────────────────────────────────────

    private resolveCrop(commodityName: string): Crop | null {
        const key = commodityName.trim().toLowerCase();
        // Try explicit mapping first
        const mappedName = COMMODITY_NAME_MAP[key];
        if (mappedName && this.cropNameMap!.has(mappedName.toLowerCase())) {
            return this.cropNameMap!.get(mappedName.toLowerCase())!;
        }
        // Fall back to direct match against crop.nameEn
        if (this.cropNameMap!.has(key)) {
            return this.cropNameMap!.get(key)!;
        }
        // Try stripping bracketed text: "Bhindi(Ladies Finger)" → "bhindi"
        const stripped = key.replace(/\s*\(.*\)\s*/g, '').trim();
        if (stripped !== key) {
            const strippedMapped = COMMODITY_NAME_MAP[stripped];
            if (strippedMapped && this.cropNameMap!.has(strippedMapped.toLowerCase())) {
                return this.cropNameMap!.get(strippedMapped.toLowerCase())!;
            }
            if (this.cropNameMap!.has(stripped)) {
                return this.cropNameMap!.get(stripped)!;
            }
        }
        this.logger.debug(`Unmapped commodity skipped: "${commodityName}"`);
        return null;
    }

    // ─── Market resolution ───────────────────────────────────────────

    /** Normalize market names: trim, lowercase, strip bracketed suffixes like (F&V), (Uzhavar Sandhai) */
    private normalizeMarketName(name: string): string {
        return name.trim().toLowerCase()
            .replace(/\s*\([^)]*\)\s*/g, '')   // strip (…)
            .replace(/\s+apmc$/i, '')            // strip trailing " APMC"
            .trim();
    }

    private async resolveOrCreateMarket(
        rec: MandiApiRecord,
    ): Promise<{ market: Market; isNew: boolean }> {
        const marketName = rec.market.trim();
        const district = rec.district.trim();
        const lookupKey = `${marketName.toLowerCase()}|${district.toLowerCase()}`;

        // Check in-memory cache (exact name + district)
        if (this.marketDistrictMap!.has(lookupKey)) {
            return { market: this.marketDistrictMap!.get(lookupKey)!, isNew: false };
        }

        // Try normalized name match: strip brackets/APMC, compare against existing markets in same district
        const normalizedApi = this.normalizeMarketName(marketName);
        for (const [key, mkt] of this.marketDistrictMap!.entries()) {
            const [existingName, existingDistrict] = key.split('|');
            if (existingDistrict === district.toLowerCase()) {
                const normalizedExisting = this.normalizeMarketName(existingName);
                if (normalizedApi === normalizedExisting ||
                    normalizedApi.includes(normalizedExisting) ||
                    normalizedExisting.includes(normalizedApi)) {
                    // Cache this alias for future lookups
                    this.marketDistrictMap!.set(lookupKey, mkt);
                    return { market: mkt, isNew: false };
                }
            }
        }

        // Create new market
        const newMarket = this.marketRepo.create({
            id: `m-api-${uuidv4().slice(0, 28)}`,
            nameEn: marketName,
            nameTa: marketName,   // Tamil name unavailable from API
            district,
            state: rec.state.trim() || this.STATE_FILTER,
            isActive: true,
        });
        const saved = await this.marketRepo.save(newMarket);
        // Update cache
        this.marketDistrictMap!.set(lookupKey, saved);
        this.logger.log(`Auto-created market: ${marketName} (${district})`);
        return { market: saved, isNew: true };
    }

    // ─── Upsert ──────────────────────────────────────────────────────

    private async upsertPrice(data: {
        cropId: string;
        marketId: string;
        recordDate: string;
        minPrice: number;
        maxPrice: number;
        modalPrice: number;
        pricePerKg: number;
    }): Promise<boolean> {
        const priceId = `p-api-${uuidv4().slice(0, 28)}`;
        // Use xmax trick: xmax = 0 means fresh insert, xmax != 0 means update
        const rows: Array<{ xmax: string }> = await this.cropPriceRepo.query(
            `INSERT INTO crop_prices (id, crop_id, market_id, record_date, price_per_kg, min_price, max_price, modal_price, source, quality_grade)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
             ON CONFLICT (crop_id, market_id, record_date)
             DO UPDATE SET min_price = EXCLUDED.min_price,
                          max_price = EXCLUDED.max_price,
                          modal_price = EXCLUDED.modal_price,
                          price_per_kg = EXCLUDED.price_per_kg,
                          source = EXCLUDED.source
             RETURNING xmax`,
            [
                priceId,
                data.cropId,
                data.marketId,
                data.recordDate,
                data.pricePerKg,
                data.minPrice,
                data.maxPrice,
                data.modalPrice,
                'data.gov.in',
                'A',
            ],
        );
        return rows.length > 0 && rows[0].xmax !== '0';
    }

    // ─── Helpers ─────────────────────────────────────────────────────

    private async buildCropCache(): Promise<void> {
        const crops = await this.cropRepo.find();
        this.cropNameMap = new Map(
            crops.map((c) => [c.nameEn.toLowerCase(), c]),
        );
    }

    private async buildMarketCache(): Promise<void> {
        const markets = await this.marketRepo.find();
        this.marketDistrictMap = new Map(
            markets.map((m) => [`${m.nameEn.toLowerCase()}|${m.district.toLowerCase()}`, m]),
        );
    }

    /** Convert DD/MM/YYYY → YYYY-MM-DD, returns null if unparseable. */
    private parseDate(raw: string): string | null {
        if (!raw) return null;
        // Handle DD/MM/YYYY
        const parts = raw.trim().split('/');
        if (parts.length === 3) {
            const [dd, mm, yyyy] = parts;
            const d = parseInt(dd, 10);
            const m = parseInt(mm, 10);
            const y = parseInt(yyyy, 10);
            if (d > 0 && d <= 31 && m > 0 && m <= 12 && y > 2000) {
                return `${yyyy}-${mm.padStart(2, '0')}-${dd.padStart(2, '0')}`;
            }
        }
        // Handle ISO or YYYY-MM-DD
        if (/^\d{4}-\d{2}-\d{2}/.test(raw.trim())) {
            return raw.trim().slice(0, 10);
        }
        return null;
    }

    /** Convert price-per-quintal string to price-per-kg number. 1 quintal = 100 kg */
    private quintalToKg(priceStr: string): number {
        const val = parseFloat(priceStr);
        if (isNaN(val) || val <= 0) return 0;
        return Math.round((val / 100) * 100) / 100; // 2 decimal places
    }
}

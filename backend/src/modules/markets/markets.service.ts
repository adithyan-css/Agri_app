import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Market } from './entities/market.entity';
import { NearbyMarketsDto } from './dto/nearby-markets.dto';
import { CropsService } from '../crops/crops.service';

// Default transport cost rate: ₹15 per km (typical truck fare in Tamil Nadu)
const DEFAULT_TRANSPORT_RATE_PER_KM = 15;

@Injectable()
export class MarketsService {
    private readonly logger = new Logger(MarketsService.name);

    constructor(
        @InjectRepository(Market)
        private readonly marketRepository: Repository<Market>,
        private readonly cropsService: CropsService,
    ) { }

    async findAll(): Promise<Market[]> {
        return this.marketRepository.find({ where: { isActive: true } });
    }

    /**
     * Finds nearby markets using PostGIS ST_Distance computation
     * Formula: ST_Distance returns meters for geography types
     */
    async findNearbyMarkets(query: NearbyMarketsDto): Promise<Market[]> {
        const radiusMeters = (query.radiusKm || 50) * 1000;

        // We use QueryBuilder to inject raw PostGIS ST_Distance logic
        // This allows PostgreSQL to sort locations blazingly fast using GIST index
        const markets = await this.marketRepository
            .createQueryBuilder('market')
            .addSelect(
                `ST_Distance(market.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)) / 1000`,
                'distanceKm'
            )
            .where(
                `ST_DWithin(market.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326), :radiusMeters)`
            )
            .andWhere('market.isActive = true')
            .setParameters({
                lng: query.lng,
                lat: query.lat,
                radiusMeters
            })
            .orderBy('distanceKm', 'ASC')
            .getRawAndEntities();

        // Map raw DB distance back into entities for clean return
        return markets.entities.map((entity, index) => {
            // TypeORM's getRawAndEntities maps the raw ST_Distance result at the matching index
            entity.distanceKm = Math.round(markets.raw[index].distanceKm * 10) / 10;
            return entity;
        });
    }

    /**
     * Nearby Market Profit Optimizer
     * ──────────────────────────────
     * Finds markets within the given radius, fetches the latest crop price
     * at each market, calculates transport cost, and returns profit analysis.
     *
     * Output per market:
     *   - market_name, distance, price, transport_cost, profit_after_transport
     *
     * Markets are sorted by profit_after_transport (highest first).
     */
    async findNearbyMarketsWithProfit(query: NearbyMarketsDto): Promise<any[]> {
        // Step 1: Find all nearby markets using PostGIS
        const nearbyMarkets = await this.findNearbyMarkets(query);

        if (!query.cropId || nearbyMarkets.length === 0) {
            // If no cropId provided, return markets without profit data
            return nearbyMarkets.map(m => ({
                marketId: m.id,
                marketName: m.nameEn,
                marketNameTa: m.nameTa,
                district: m.district,
                state: m.state,
                distanceKm: m.distanceKm || 0,
                pricePerKg: null,
                transportCostPerKg: null,
                profitAfterTransport: null,
                isActive: m.isActive,
            }));
        }

        // Step 2: For each nearby market, look up the latest crop price
        const results = await Promise.all(
            nearbyMarkets.map(async (market) => {
                const distance = market.distanceKm || 0;

                // Calculate transport cost per kg
                // Formula: (distance_km * rate_per_km) / assumed_load_kg
                // We assume a standard load of 1000 kg for per-kg cost calculation
                const transportCostTotal = distance * DEFAULT_TRANSPORT_RATE_PER_KM;
                const transportCostPerKg = Number((transportCostTotal / 1000).toFixed(2));

                let pricePerKg = 0;
                try {
                    const latestPrice = await this.cropsService.getLatestPrice(query.cropId!, market.id);
                    pricePerKg = Number(latestPrice.pricePerKg);
                } catch {
                    // No price data for this crop at this market
                    this.logger.warn(`No price data for crop ${query.cropId} at market ${market.id}`);
                }

                // Profit after transport = selling price - transport cost
                const profitAfterTransport = Number((pricePerKg - transportCostPerKg).toFixed(2));

                return {
                    marketId: market.id,
                    marketName: market.nameEn,
                    marketNameTa: market.nameTa,
                    district: market.district,
                    state: market.state,
                    distanceKm: distance,
                    pricePerKg,
                    transportCostPerKg,
                    profitAfterTransport,
                    isActive: market.isActive,
                };
            })
        );

        // Step 3: Sort by profit (highest first) — the most profitable market is at index 0
        results.sort((a, b) => (b.profitAfterTransport ?? 0) - (a.profitAfterTransport ?? 0));

        // Tag the best market
        if (results.length > 0) {
            results[0]['isBestMarket'] = true;
        }

        return results;
    }
}

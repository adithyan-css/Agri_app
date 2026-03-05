import { Injectable, Logger } from '@nestjs/common';
import { MarketsService } from '../markets/markets.service';
import { CropsService } from '../crops/crops.service';
import { RoutingService } from './routing.service';
import { RoadProfitQueryDto } from './dto/road-profit-query.dto';

const DEFAULT_TRANSPORT_RATE_PER_KM = 15; // ₹15/km typical Tamil Nadu truck fare

export interface RoadProfitResult {
    marketId: string;
    marketName: string;
    marketNameTa: string;
    district: string;
    state: string;
    roadDistanceKm: number;
    travelTimeMinutes: number;
    pricePerKg: number;
    grossRevenue: number;
    transportCost: number;
    netProfit: number;
    profitPerKg: number;
    isProfitable: boolean;
    isBestMarket: boolean;
}

@Injectable()
export class RoadProfitService {
    private readonly logger = new Logger(RoadProfitService.name);

    constructor(
        private readonly marketsService: MarketsService,
        private readonly cropsService: CropsService,
        private readonly routingService: RoutingService,
    ) {}

    /**
     * Find the top 5 most profitable nearby markets using real road distance.
     *
     * Steps:
     *  1. Use PostGIS to find markets within radiusKm (straight-line pre-filter)
     *  2. Call OpenRouteService to get real road distance for each
     *  3. Fetch latest crop price at each market
     *  4. Calculate profit = (price * qty) - (roadDistance * transportRate)
     *  5. Return top 5 sorted by net profit descending
     */
    async findProfitableMarkets(dto: RoadProfitQueryDto): Promise<RoadProfitResult[]> {
        // Step 1: Pre-filter markets within radius using PostGIS (cheap)
        const nearbyMarkets = await this.marketsService.findNearbyMarkets({
            lat: dto.farmerLat,
            lng: dto.farmerLng,
            radiusKm: dto.radiusKm ?? 100,
        });

        if (nearbyMarkets.length === 0) {
            return [];
        }

        // Step 2: Get all markets' lat/lng from DB (for ORS call)
        const allMarkets = await this.marketsService.findAll();
        const marketMap = new Map(allMarkets.map(m => [m.id, m]));

        // Step 3: Call OpenRouteService for real road distances
        const destinations = nearbyMarkets
            .map(m => {
                const full = marketMap.get(m.id);
                if (!full || !full.lat || !full.lng) return null;
                return { id: m.id, lng: full.lng, lat: full.lat };
            })
            .filter(Boolean) as { id: string; lng: number; lat: number }[];

        const routes = await this.routingService.getRoutesToMany(
            dto.farmerLng,
            dto.farmerLat,
            destinations,
        );

        // Step 4: Calculate profit for each market
        const results: RoadProfitResult[] = [];

        for (const market of nearbyMarkets) {
            const route = routes.get(market.id);
            if (!route) continue; // Skip if route failed

            const full = marketMap.get(market.id);
            if (!full) continue;

            let pricePerKg = 0;
            try {
                const latest = await this.cropsService.getLatestPrice(dto.cropId, market.id);
                pricePerKg = Number(latest.pricePerKg ?? latest.price ?? 0);
            } catch {
                this.logger.warn(`No price for crop ${dto.cropId} at market ${market.id}`);
                continue; // Skip markets without price data
            }

            const grossRevenue = pricePerKg * dto.quantity;
            const transportCost = route.distanceKm * DEFAULT_TRANSPORT_RATE_PER_KM;
            const netProfit = grossRevenue - transportCost;
            const profitPerKg = dto.quantity > 0 ? netProfit / dto.quantity : 0;

            results.push({
                marketId: market.id,
                marketName: full.nameEn,
                marketNameTa: full.nameTa,
                district: full.district,
                state: full.state,
                roadDistanceKm: route.distanceKm,
                travelTimeMinutes: route.durationMinutes,
                pricePerKg,
                grossRevenue: Math.round(grossRevenue * 100) / 100,
                transportCost: Math.round(transportCost * 100) / 100,
                netProfit: Math.round(netProfit * 100) / 100,
                profitPerKg: Math.round(profitPerKg * 100) / 100,
                isProfitable: netProfit > 0,
                isBestMarket: false,
            });
        }

        // Step 5: Sort by net profit descending, take top 5
        results.sort((a, b) => b.netProfit - a.netProfit);
        const top5 = results.slice(0, 5);

        if (top5.length > 0) {
            top5[0].isBestMarket = true;
        }

        return top5;
    }
}

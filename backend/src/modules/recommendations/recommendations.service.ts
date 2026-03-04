import { Injectable, Logger } from '@nestjs/common';
import { TransportProfitDto } from './dto/transport-profit.dto';
import { CropsService } from '../crops/crops.service';

@Injectable()
export class RecommendationsService {
    private readonly logger = new Logger(RecommendationsService.name);

    constructor(
        private readonly cropsService: CropsService,
    ) { }

    /**
     * Calculates real-world profit when taking a crop to a specific market.
     * Logic: (Market Price * Volume) - (Transport Distance * Transport Rate)
     */
    async calculateTransportProfit(dto: TransportProfitDto): Promise<any> {
        const latestPrice = await this.cropsService.getLatestPrice(dto.cropId, dto.targetMarketId);

        const grossRevenue = Number(latestPrice.pricePerKg) * dto.volumeKg;
        const transportCost = dto.distanceKm * dto.perKmRate;
        const netProfit = grossRevenue - transportCost;

        return {
            cropId: dto.cropId,
            marketId: dto.targetMarketId,
            currentPricePerKg: Number(latestPrice.pricePerKg),
            grossRevenue,
            transportCost,
            netProfit,
            isProfitable: netProfit > 0,
            marginPercentage: grossRevenue > 0 ? ((netProfit / grossRevenue) * 100).toFixed(2) : 0
        };
    }
}

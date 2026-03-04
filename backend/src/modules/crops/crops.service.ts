import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Crop } from './entities/crop.entity';
import { CropPrice } from './entities/crop-price.entity';
import { RedisService } from 'nestjs-redis';

@Injectable()
export class CropsService {
    constructor(
        @InjectRepository(Crop)
        private cropRepository: Repository<Crop>,
        @InjectRepository(CropPrice)
        private cropPriceRepository: Repository<CropPrice>,
        private readonly redisService: RedisService,
    ) { }

    async findAllCrops(): Promise<Crop[]> {
        const client = this.redisService.getClient();
        const cachedCrops = await client.get('all_crops');
        if (cachedCrops) return JSON.parse(cachedCrops);

        const crops = await this.cropRepository.find();

        await client.set('all_crops', JSON.stringify(crops), 'EX', 86400); // 24h
        return crops;
    }

    async getHistoricalPrices(cropId: string, marketId: string, days: number = 7): Promise<CropPrice[]> {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        return this.cropPriceRepository.find({
            where: {
                cropId,
                marketId,
                recordDate: Between(startDate, endDate)
            },
            order: { recordDate: 'ASC' }
        });
    }

    async getLatestPrice(cropId: string, marketId: string): Promise<CropPrice> {
        const cacheKey = `latest_price:${cropId}:${marketId}`;
        const client = this.redisService.getClient();

        const cached = await client.get(cacheKey);
        if (cached) return JSON.parse(cached);

        const price = await this.cropPriceRepository.findOne({
            where: { cropId, marketId },
            order: { recordDate: 'DESC' }
        });

        if (!price) throw new NotFoundException('Price not found for this crop and market.');

        await client.set(cacheKey, JSON.stringify(price), 'EX', 3600); // 1hr cache
        return price;
    }
}

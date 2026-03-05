import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Crop } from './entities/crop.entity';
import { CropPrice } from './entities/crop-price.entity';

@Injectable()
export class CropsService {
    constructor(
        @InjectRepository(Crop)
        private cropRepository: Repository<Crop>,
        @InjectRepository(CropPrice)
        private cropPriceRepository: Repository<CropPrice>,
    ) { }

    async findAllCrops(): Promise<Crop[]> {
        return this.cropRepository.find();
    }

    async getHistoricalPrices(cropId: string, marketId: string, days: number = 7) {
        // Find the most recent record for this crop/market to anchor our window
        const mostRecent = await this.cropPriceRepository.findOne({
            where: { cropId, marketId },
            order: { recordDate: 'DESC' }
        });

        let records: CropPrice[];

        if (!mostRecent) {
            // If no market-specific data, find any recent record for this crop
            const anyCrop = await this.cropPriceRepository.findOne({
                where: { cropId },
                order: { recordDate: 'DESC' }
            });
            if (!anyCrop) return [];

            // Get the last N days of data for this crop across any market
            const endDate = new Date(anyCrop.recordDate);
            const startDate = new Date(anyCrop.recordDate);
            startDate.setDate(startDate.getDate() - days);
            records = await this.cropPriceRepository.find({
                where: { cropId, recordDate: Between(startDate, endDate) },
                order: { recordDate: 'ASC' },
                take: days
            });
        } else {
            const endDate = new Date(mostRecent.recordDate);
            const startDate = new Date(mostRecent.recordDate);
            startDate.setDate(startDate.getDate() - days);

            records = await this.cropPriceRepository.find({
                where: {
                    cropId,
                    marketId,
                    recordDate: Between(startDate, endDate)
                },
                order: { recordDate: 'ASC' }
            });
        }

        // Add Flutter-compatible aliases
        return records.map(r => ({ ...r, price: r.pricePerKg, date: r.recordDate }));
    }

    async getLatestPrice(cropId: string, marketId: string) {
        const record = await this.cropPriceRepository.findOne({
            where: { cropId, marketId },
            order: { recordDate: 'DESC' }
        });

        if (!record) throw new NotFoundException('Price not found for this crop and market.');

        return { ...record, price: record.pricePerKg };
    }
}

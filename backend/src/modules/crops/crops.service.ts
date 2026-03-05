import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, In } from 'typeorm';
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

    /**
     * Find the latest price for a crop at ANY market.
     * Used as fallback when the selected market has no data.
     * Returns the record plus the market_id that was used.
     */
    async getLatestPriceAnyMarket(cropId: string) {
        const record = await this.cropPriceRepository.findOne({
            where: { cropId },
            order: { recordDate: 'DESC' }
        });

        if (!record) throw new NotFoundException('No price data exists for this crop.');

        return { ...record, price: record.pricePerKg };
    }

    /**
     * Get the latest price for every crop at a specific market.
     * Falls back to any-market price when a crop has no data at the selected market.
     * Returns an array of { cropId, nameEn, nameTa, price, marketId, recordDate, source }.
     */
    async getAllCropPricesForMarket(marketId: string): Promise<any[]> {
        const crops = await this.cropRepository.find();

        // Get the latest price per crop at this market using a raw query for efficiency
        const marketPrices: CropPrice[] = await this.cropPriceRepository
            .createQueryBuilder('cp')
            .distinctOn(['cp.crop_id'])
            .where('cp.market_id = :marketId', { marketId })
            .orderBy('cp.crop_id')
            .addOrderBy('cp.record_date', 'DESC')
            .getMany();

        const marketPriceMap = new Map<string, CropPrice>();
        for (const mp of marketPrices) {
            marketPriceMap.set(mp.cropId, mp);
        }

        // For crops missing at this market, get the latest price from any market
        const missingCropIds = crops
            .map(c => c.id)
            .filter(id => !marketPriceMap.has(id));

        const fallbackPrices: CropPrice[] = missingCropIds.length > 0
            ? await this.cropPriceRepository
                .createQueryBuilder('cp')
                .distinctOn(['cp.crop_id'])
                .where('cp.crop_id IN (:...ids)', { ids: missingCropIds })
                .orderBy('cp.crop_id')
                .addOrderBy('cp.record_date', 'DESC')
                .getMany()
            : [];

        const fallbackMap = new Map<string, CropPrice>();
        for (const fp of fallbackPrices) {
            fallbackMap.set(fp.cropId, fp);
        }

        return crops.map(crop => {
            const mp = marketPriceMap.get(crop.id);
            const fp = fallbackMap.get(crop.id);
            const record = mp || fp;
            return {
                cropId: crop.id,
                nameEn: crop.nameEn,
                nameTa: crop.nameTa,
                category: crop.category,
                price: record ? Number(record.pricePerKg) : 0,
                marketId: record?.marketId ?? marketId,
                recordDate: record?.recordDate ?? null,
                source: mp ? 'selected_market' : (fp ? 'nearby_market' : 'none'),
            };
        });
    }
}

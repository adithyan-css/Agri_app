import { Injectable, OnApplicationBootstrap, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DataIngestionService } from './data-ingestion.service';
import { Crop } from '../crops/entities/crop.entity';
import { Market } from '../markets/entities/market.entity';
import { CropPrice } from '../crops/entities/crop-price.entity';
import { Truck } from '../transport/entities/transport.entity';

@Injectable()
export class SeedService implements OnApplicationBootstrap {
    private readonly logger = new Logger(SeedService.name);

    constructor(
        @InjectRepository(Crop)
        private cropRepository: Repository<Crop>,
        @InjectRepository(Market)
        private marketRepository: Repository<Market>,
        @InjectRepository(CropPrice)
        private priceRepository: Repository<CropPrice>,
        @InjectRepository(Truck)
        private truckRepository: Repository<Truck>,
        private ingestionService: DataIngestionService,
    ) { }

    async onApplicationBootstrap() {
        const cropCount = await this.cropRepository.count();
        if (cropCount === 0) {
            await this.seedCrops();
            await this.seedMarkets();
            await this.seedPrices();
            await this.seedTrucks();
            this.logger.log('Database Basic Seeding Successfully! 🌱');
        }

        // Independent check for historical data from the large dataset
        const priceCount = await this.priceRepository.count();
        if (priceCount < 100) {
            this.logger.log('Historical price data missing or insufficient. Starting dataset ingestion...');
            this.ingestionService.startIngestion().catch(err => {
                this.logger.error('Historical ingestion failed:', err);
            });
        }
    }

    private async seedCrops() {
        const crops = [
            { nameEn: 'Tomato', nameTa: 'தக்காளி', category: 'Vegetable', baseShelfLifeDays: 7 },
            { nameEn: 'Onion', nameTa: 'வெங்காயம்', category: 'Vegetable', baseShelfLifeDays: 45 },
            { nameEn: 'Potato', nameTa: 'உருளைக்கிழங்கு', category: 'Vegetable', baseShelfLifeDays: 60 },
            { nameEn: 'Rice', nameTa: 'அரிசி', category: 'Grain', baseShelfLifeDays: 365 },
            { nameEn: 'Wheat', nameTa: 'கோதுமை', category: 'Grain', baseShelfLifeDays: 365 },
        ];
        await this.cropRepository.save(crops);
    }

    private async seedMarkets() {
        const markets = [
            {
                nameEn: 'Coimbatore Market',
                nameTa: 'கோயம்புத்தூர் சந்தை',
                district: 'Coimbatore',
                state: 'Tamil Nadu',
                location: { type: 'Point', coordinates: [76.9558, 11.0168] }
            },
            {
                nameEn: 'Salem Market',
                nameTa: 'சேலம் சந்தை',
                district: 'Salem',
                state: 'Tamil Nadu',
                location: { type: 'Point', coordinates: [78.1460, 11.6643] }
            },
            {
                nameEn: 'Madurai Market',
                nameTa: 'மதுரை சந்தை',
                district: 'Madurai',
                state: 'Tamil Nadu',
                location: { type: 'Point', coordinates: [78.1198, 9.9252] }
            },
            {
                nameEn: 'Erode Market',
                nameTa: 'ஈரோடு சந்தை',
                district: 'Erode',
                state: 'Tamil Nadu',
                location: { type: 'Point', coordinates: [77.7172, 11.3410] }
            }
        ];

        // Note: Using raw SQL or specific TypeORM handlers for PostGIS if simple save fails
        // For now, attempting standard save which works with some TypeORM PostGIS drivers
        await this.marketRepository.save(markets);
    }

    private async seedPrices() {
        const tomato = await this.cropRepository.findOne({ where: { nameEn: 'Tomato' } });
        const coimbatore = await this.marketRepository.findOne({ where: { district: 'Coimbatore' } });

        if (tomato && coimbatore) {
            const prices = [];
            const today = new Date();
            for (let i = 30; i >= 0; i--) {
                const date = new Date(today);
                date.setDate(today.getDate() - i);
                prices.push({
                    cropId: tomato.id,
                    marketId: coimbatore.id,
                    pricePerKg: 20 + Math.random() * 20,
                    recordDate: date,
                    qualityGrade: 'A'
                });
            }
            await this.priceRepository.save(prices);
        }
    }

    private async seedTrucks() {
        const trucks = [
            { licensePlate: 'TN-38-AX-1234', driverName: 'Suresh Kumar', driverPhone: '9876543210', capacityKg: 5000, perKmRate: 15.0, isAvailable: true },
            { licensePlate: 'TN-33-BY-5678', driverName: 'Palani Swamy', driverPhone: '9876543211', capacityKg: 3000, perKmRate: 12.0, isAvailable: true },
            { licensePlate: 'TN-45-CZ-9012', driverName: 'Ramesh Babu', driverPhone: '9876543212', capacityKg: 10000, perKmRate: 25.0, isAvailable: true },
        ];
        await this.truckRepository.save(trucks);
    }
}

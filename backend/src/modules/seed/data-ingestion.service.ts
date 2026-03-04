import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as csv from 'csv-parser';
import * as moment from 'moment';
import { Crop } from '../crops/entities/crop.entity';
import { Market } from '../markets/entities/market.entity';
import { CropPrice } from '../crops/entities/crop-price.entity';

@Injectable()
export class DataIngestionService {
    private readonly logger = new Logger(DataIngestionService.name);
    private readonly batchSize = 5000;
    private readonly csvPath = process.env.DATASET_CSV_PATH || '/usr/src/app/dataset/Agriculture_price_dataset.csv';

    constructor(
        @InjectRepository(Crop)
        private cropRepository: Repository<Crop>,
        @InjectRepository(Market)
        private marketRepository: Repository<Market>,
        @InjectRepository(CropPrice)
        private priceRepository: Repository<CropPrice>,
    ) { }

    async startIngestion() {
        this.logger.log(`Starting Master Dataset Ingestion from: ${this.csvPath}`);

        if (!fs.existsSync(this.csvPath)) {
            this.logger.error(`Dataset file not found at ${this.csvPath}. Skipping ingestion.`);
            return;
        }

        // 1. Prepare fast lookup maps
        const crops = await this.cropRepository.find();
        const initialMarkets = await this.marketRepository.find();

        const cropMap = new Map<string, string>();
        crops.forEach(c => cropMap.set(c.nameEn.toLowerCase(), c.id));

        const marketMap = new Map<string, string>();
        initialMarkets.forEach(m => marketMap.set(m.district.toLowerCase(), m.id));

        let processedCount = 0;
        let skippedCount = 0;
        let batch: Partial<CropPrice>[] = [];

        return new Promise((resolve, reject) => {
            const stream = fs.createReadStream(this.csvPath).pipe(csv());

            stream.on('data', async (row) => {
                const state = row['STATE'] || '';
                const districtName = row['District Name'] || '';
                const commodity = row['Commodity']?.toLowerCase() || '';
                const variety = row['Variety']?.toLowerCase() || '';
                const modalPriceRaw = row['Modal_Price'];
                const dateStr = row['Price Date'];

                // 1. Validate Price
                const modalPrice = parseFloat(modalPriceRaw);
                if (isNaN(modalPrice)) {
                    skippedCount++;
                    return;
                }

                // 2. Validate Date
                const recordDate = moment(dateStr, 'D/M/YYYY', true);
                if (!recordDate.isValid()) {
                    skippedCount++;
                    return;
                }

                // 3. Match Crop
                let cropId = '';
                for (const [name, id] of cropMap.entries()) {
                    if (commodity.includes(name) || variety.includes(name)) {
                        cropId = id;
                        break;
                    }
                }

                if (!cropId) {
                    skippedCount++;
                    return;
                }

                // 4. Match or Create Market
                let districtKey = districtName.toLowerCase().trim();
                let marketId = marketMap.get(districtKey);

                if (!marketId && districtKey) {
                    stream.pause();
                    try {
                        const newMarket = await this.marketRepository.save({
                            nameEn: `${districtName} Market`,
                            nameTa: districtName,
                            district: districtName,
                            state: state,
                            location: { type: 'Point', coordinates: [77.0, 11.0] }
                        });
                        marketId = newMarket.id;
                        marketMap.set(districtKey, marketId);
                    } catch (err) {
                        this.logger.error(`Failed to create market for ${districtName}`, err);
                    }
                    stream.resume();
                }

                if (marketId) {
                    batch.push({
                        cropId,
                        marketId,
                        pricePerKg: modalPrice / 100,
                        recordDate: recordDate.toDate(),
                        qualityGrade: 'A'
                    });

                    processedCount++;

                    if (batch.length >= this.batchSize) {
                        stream.pause();
                        const currentBatch = [...batch];
                        batch = [];
                        try {
                            await this.priceRepository.insert(currentBatch);
                            if (processedCount % 10000 === 0) {
                                this.logger.log(`Ingested ${processedCount} records (Skipped: ${skippedCount})...`);
                            }
                        } catch (err) {
                            this.logger.error('Batch insert failed', err);
                        }
                        stream.resume();
                    }
                } else {
                    skippedCount++;
                }
            })
                .on('end', async () => {
                    if (batch.length > 0) {
                        try {
                            await this.priceRepository.insert(batch);
                        } catch (err) {
                            this.logger.error('Final batch insert failed', err);
                        }
                    }
                    this.logger.log(`Ingestion completed! Total processed: ${processedCount}, Skipped: ${skippedCount}`);
                    resolve(processedCount);
                })
                .on('error', (err) => {
                    this.logger.error('Error during CSV ingestion', err);
                    reject(err);
                });
        });
    }
}

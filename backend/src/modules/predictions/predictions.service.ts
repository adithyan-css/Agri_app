import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Prediction } from './entities/prediction.entity';
import { CropsService } from '../crops/crops.service';
import axios from 'axios';
import * as moment from 'moment';

@Injectable()
export class PredictionsService {
    private readonly logger = new Logger(PredictionsService.name);

    constructor(
        @InjectRepository(Prediction)
        private readonly predictionRepository: Repository<Prediction>,
        private readonly cropsService: CropsService,
        private readonly configService: ConfigService,
    ) { }

    async getAiForecast(cropId: string, marketId: string): Promise<any> {
        // 1. Check if we have fresh predictions for today
        const existing = await this.predictionRepository.find({
            where: {
                cropId,
                marketId,
                generatedAt: Between(moment().startOf('day').toDate(), moment().endOf('day').toDate())
            },
            order: { targetDate: 'ASC' }
        });

        if (existing.length > 0) {
            return { source: 'database_cache', data: existing };
        }

        // 2. We don't have predictions today, proxy call to FastAPI Python Service
        try {
            // Get 30 days of historical data for the model context
            const history = await this.cropsService.getHistoricalPrices(cropId, marketId, 30);

            const mlServiceUrl = this.configService.get<string>('ML_SERVICE_URL', 'http://localhost:8000');

            const payload = {
                crop_id: cropId,
                market_id: marketId,
                use_model: 'chronos',
                historical_data: history.map(h => ({
                    date: moment(h.recordDate).format('YYYY-MM-DD'),
                    price: Number(h.pricePerKg)
                }))
            };

            this.logger.log(`Requesting forecast from ML Service at ${mlServiceUrl}/predict`);

            const response = await axios.post(`${mlServiceUrl}/predict`, payload);
            const predictionResponse = response.data;

            // 3. Store new predictions in our PostgreSQL database for caching
            const newEntities = predictionResponse.predictions.map(p => this.predictionRepository.create({
                cropId,
                marketId,
                targetDate: p.date,
                predictedPrice: p.predicted_price,
                lowerBound: p.lower_bound,
                upperBound: p.upper_bound,
                confidenceScore: predictionResponse.confidence_score,
                modelUsed: 'chronos' // hardcoded to ensemble request choice
            }));

            await this.predictionRepository.save(newEntities);

            // Return full detailed analysis combining raw points with logic
            return {
                source: 'ml_service_fresh',
                trend: predictionResponse.trend_direction,
                recommendation: predictionResponse.recommendation,
                confidence: predictionResponse.confidence_score,
                data: newEntities
            };

        } catch (error) {
            this.logger.error('Failed to generate predictions via ML Service', error.message);
            throw new Error('Prediction Engine is currently unavailable');
        }
    }
}

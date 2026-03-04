import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Prediction } from './entities/prediction.entity';
import { CropsService } from '../crops/crops.service';
import axios from 'axios';
import { Market } from '../markets/entities/market.entity';
import { WeatherService } from '../weather/weather.service';
import * as moment from 'moment';

@Injectable()
export class PredictionsService {
    private readonly logger = new Logger(PredictionsService.name);

    constructor(
        @InjectRepository(Prediction)
        private readonly predictionRepository: Repository<Prediction>,
        private readonly cropsService: CropsService,
        private readonly configService: ConfigService,
        private readonly weatherService: WeatherService,
        @InjectRepository(Market)
        private readonly marketRepository: Repository<Market>,
    ) { }

    async getAiForecast(cropId: string, marketId: string): Promise<any> {
        // ... (existing cache check)
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

        try {
            // 2a. Fetch Market Coordinates for Weather Lookup
            const marketData = await this.marketRepository.createQueryBuilder('market')
                .select([
                    'market.id',
                    'ST_X(market.location) AS lng',
                    'ST_Y(market.location) AS lat'
                ])
                .where('market.id = :marketId', { marketId })
                .getRawOne();

            // 2b. Fetch Current Weather for the market
            const weather = await this.weatherService.getMarketWeather(
                marketData?.lat || 11.0168, // Fallback to Coimbatore
                marketData?.lng || 76.9558
            );

            // 3. We don't have predictions today, proxy call to FastAPI Python Service
            const history = await this.cropsService.getHistoricalPrices(cropId, marketId, 90);
            const mlServiceUrl = this.configService.get<string>('ML_SERVICE_URL', 'http://localhost:8000');

            const payload = {
                crop_id: cropId,
                market_id: marketId,
                use_model: 'chronos',
                weather_forecast: {
                    temp: weather.tempCelsius,
                    rainfall: weather.rainfallMm,
                    humidity: weather.humidityPercent,
                    conditions: weather.conditions
                },
                historical_data: history.map(h => ({
                    date: moment(h.recordDate).format('YYYY-MM-DD'),
                    price: Number(h.pricePerKg)
                }))
            };

            this.logger.log(`Requesting weather-aware forecast from ML Service at ${mlServiceUrl}/predict`);

            const response = await axios.post(`${mlServiceUrl}/predict`, payload);
            const predictionResponse = response.data;

            // 4. Store new predictions ... (rest of storage logic)
            const newEntities = predictionResponse.predictions.map(p => this.predictionRepository.create({
                cropId,
                marketId,
                targetDate: p.date,
                predictedPrice: p.predicted_price,
                lowerBound: p.lower_bound,
                upperBound: p.upper_bound,
                confidenceScore: predictionResponse.confidence_score,
                modelUsed: 'chronos'
            }));

            await this.predictionRepository.save(newEntities);

            return {
                source: 'ml_service_fresh',
                weather_context: weather,
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

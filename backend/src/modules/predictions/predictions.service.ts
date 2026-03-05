import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
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
        // Resolve 'default' to the first market in the DB
        if (!marketId || marketId === 'default') {
            const fallback = await this.marketRepository.findOne({ where: {}, order: { nameEn: 'ASC' } });
            if (fallback) marketId = fallback.id;
        }

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
            // Compute trend, recommendation, and confidence from cached predictions
            const prices = existing.map(p => Number(p.predictedPrice));
            const first = prices[0];
            const last = prices[prices.length - 1];
            let trend = 'STABLE';
            if (last > first * 1.02) trend = 'UP';
            else if (last < first * 0.98) trend = 'DOWN';

            const recommendation = trend === 'UP' ? 'WAIT' : 'SELL';
            const confidenceScores = existing.map(p => Number(p.confidenceScore || 0));
            const confidence = confidenceScores.reduce((a, b) => a + b, 0) / confidenceScores.length;

            return { source: 'database_cache', trend, recommendation, confidence, data: existing };
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
            throw new ServiceUnavailableException('Prediction Engine is currently unavailable');
        }
    }

    /**
     * AI Sell or Wait Recommendation Engine
     * ──────────────────────────────────────
     * Compares the current market price with predicted future prices
     * and returns a clear recommendation: SELL now or WAIT for better prices.
     *
     * Logic:
     *   - If any predicted_price > current_price → WAIT (prices going up)
     *   - Else → SELL (prices stable or dropping, sell now)
     *
     * Returns: trend, recommendation, expected_profit, confidence
     */
    async getSellOrWaitRecommendation(cropId: string, marketId: string): Promise<any> {
        // Resolve 'default' to the first market in the DB
        if (!marketId || marketId === 'default') {
            const fallback = await this.marketRepository.findOne({ where: {}, order: { nameEn: 'ASC' } });
            if (fallback) marketId = fallback.id;
        }

        // Step 1: Get the current (latest) price for this crop at this market
        const latestPrice = await this.cropsService.getLatestPrice(cropId, marketId);
        const currentPrice = Number(latestPrice.pricePerKg);

        // Step 2: Get the AI forecast (uses cache or calls ML service)
        const forecast = await this.getAiForecast(cropId, marketId);
        const predictions: Prediction[] = forecast.data;

        if (!predictions || predictions.length === 0) {
            return {
                recommendation: 'SELL',
                trend: 'UNKNOWN',
                currentPrice,
                predictedPrice: currentPrice,
                expectedProfit: 0,
                confidence: 0,
                reason: 'No prediction data available. Selling now is the safer option.',
                predictions: [],
            };
        }

        // Step 3: Find the highest predicted price in the forecast window
        const predictedPrices = predictions.map(p => Number(p.predictedPrice));
        const maxPredictedPrice = Math.max(...predictedPrices);
        const avgPredictedPrice = predictedPrices.reduce((a, b) => a + b, 0) / predictedPrices.length;

        // Step 4: Calculate trend direction
        const firstPredicted = predictedPrices[0];
        const lastPredicted = predictedPrices[predictedPrices.length - 1];
        let trend: string;
        if (lastPredicted > firstPredicted * 1.02) {
            trend = 'UP';       // Prices rising by more than 2%
        } else if (lastPredicted < firstPredicted * 0.98) {
            trend = 'DOWN';     // Prices falling by more than 2%
        } else {
            trend = 'STABLE';   // Prices staying within ±2%
        }

        // Step 5: Apply the sell-or-wait decision rule
        //   WAIT if the max predicted price is higher than today's price (potential gain)
        //   SELL if prices are expected to stay flat or drop
        const recommendation = maxPredictedPrice > currentPrice ? 'WAIT' : 'SELL';

        // Step 6: Calculate expected profit/loss per kg
        const expectedProfit = Number((maxPredictedPrice - currentPrice).toFixed(2));

        // Step 7: Compute confidence from average prediction confidence scores
        const confidenceScores = predictions.map(p => Number(p.confidenceScore || 0));
        const avgConfidence = confidenceScores.reduce((a, b) => a + b, 0) / confidenceScores.length;
        const confidence = Number(avgConfidence.toFixed(4));

        // Step 8: Generate a human-friendly reason
        let reason: string;
        if (recommendation === 'WAIT') {
            reason = `Prices are expected to rise to ₹${maxPredictedPrice.toFixed(2)}/kg. `
                + `Waiting could yield an extra ₹${expectedProfit.toFixed(2)}/kg profit.`;
        } else {
            reason = `Prices are expected to stay flat or decline. `
                + `Selling now at ₹${currentPrice.toFixed(2)}/kg is the optimal choice.`;
        }

        return {
            recommendation,         // 'SELL' or 'WAIT'
            trend,                  // 'UP', 'DOWN', or 'STABLE'
            currentPrice,           // Today's market price per kg
            predictedPrice: Number(maxPredictedPrice.toFixed(2)),  // Best predicted price
            avgPredictedPrice: Number(avgPredictedPrice.toFixed(2)),
            expectedProfit,         // Expected gain per kg if waiting
            confidence,             // Model confidence (0-1)
            reason,                 // Human-readable explanation
            predictions: predictions.map(p => ({
                date: p.targetDate,
                price: Number(p.predictedPrice),
                lowerBound: Number(p.lowerBound),
                upperBound: Number(p.upperBound),
            })),
        };
    }
}

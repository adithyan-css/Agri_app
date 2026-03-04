import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

/**
 * ML Service Client
 * 
 * Provides a typed interface to the Python FastAPI ML service.
 * Handles request formatting, error handling, and response parsing.
 */
@Injectable()
export class MlServiceService {
    private readonly logger = new Logger(MlServiceService.name);
    private readonly mlServiceUrl: string;

    constructor(private readonly configService: ConfigService) {
        this.mlServiceUrl = this.configService.get<string>('ML_SERVICE_URL', 'http://localhost:8000');
    }

    /**
     * Check if the ML service is healthy and reachable.
     */
    async healthCheck(): Promise<{ status: string; url: string }> {
        try {
            const response = await axios.get(`${this.mlServiceUrl}/`);
            return { status: 'healthy', url: this.mlServiceUrl };
        } catch (error) {
            this.logger.error(`ML Service health check failed: ${error.message}`);
            return { status: 'unhealthy', url: this.mlServiceUrl };
        }
    }

    /**
     * Send a prediction request to the ML service.
     * 
     * @param cropId - Crop identifier
     * @param marketId - Market identifier
     * @param historicalData - Array of { date, price } objects
     * @param weatherForecast - Optional weather context for weather-aware predictions
     * @param useModel - Model to use (default: 'chronos')
     */
    async predict(params: {
        cropId: string;
        marketId: string;
        historicalData: Array<{ date: string; price: number }>;
        weatherForecast?: {
            temp: number;
            rainfall: number;
            humidity: number;
            conditions: string;
        };
        useModel?: string;
    }): Promise<any> {
        const payload = {
            crop_id: params.cropId,
            market_id: params.marketId,
            use_model: params.useModel || 'chronos',
            weather_forecast: params.weatherForecast || null,
            historical_data: params.historicalData,
        };

        try {
            this.logger.log(`Calling ML service at ${this.mlServiceUrl}/predict for crop=${params.cropId}, market=${params.marketId}`);
            const response = await axios.post(`${this.mlServiceUrl}/predict`, payload, {
                timeout: 30000, // 30 second timeout
            });
            return response.data;
        } catch (error) {
            this.logger.error(`ML Service prediction failed: ${error.message}`);
            throw new Error(`ML prediction service unavailable: ${error.message}`);
        }
    }
}
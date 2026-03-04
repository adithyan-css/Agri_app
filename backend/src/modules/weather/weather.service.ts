import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class WeatherService {
    private readonly logger = new Logger(WeatherService.name);
    private readonly apiKey: string;
    private readonly baseUrl = 'https://api.openweathermap.org/data/2.5';

    constructor(private configService: ConfigService) {
        this.apiKey = this.configService.get<string>('OPENWEATHER_API_KEY', 'mock_key');
    }

    async getMarketWeather(lat: number, lon: number): Promise<any> {
        if (this.apiKey === 'mock_key') {
            this.logger.warn('Using MOCK Weather data! OPENWEATHER_API_KEY is missing.');
            return {
                tempCelsius: 31.5,
                rainfallMm: 0,
                humidityPercent: 65,
                conditions: 'Clear',
                forecastDate: new Date()
            };
        }

        try {
            const response = await axios.get(`${this.baseUrl}/weather`, {
                params: {
                    lat,
                    lon,
                    appid: this.apiKey,
                    units: 'metric'
                }
            });

            const data = response.data;
            return {
                tempCelsius: data.main.temp,
                rainfallMm: data.rain ? data.rain['1h'] || 0 : 0,
                humidityPercent: data.main.humidity,
                conditions: data.weather[0].main,
                forecastDate: new Date()
            };
        } catch (error) {
            this.logger.error('Failed to fetch weather data', error.message);
            // Fallback to avoid breaking recommendation engine
            return {
                tempCelsius: 30,
                rainfallMm: 0,
                humidityPercent: 50,
                conditions: 'Unknown',
                forecastDate: new Date()
            };
        }
    }
}

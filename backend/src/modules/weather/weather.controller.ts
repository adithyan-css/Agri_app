import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { WeatherService } from './weather.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';

@ApiTags('Weather')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('weather')
export class WeatherController {
    constructor(private readonly weatherService: WeatherService) { }

    @Get()
    @ApiOperation({ summary: 'Get weather for a specific location (lat/lon)' })
    @ApiQuery({ name: 'lat', type: Number, example: 13.08 })
    @ApiQuery({ name: 'lon', type: Number, example: 80.27 })
    async getWeather(
        @Query('lat') lat: number,
        @Query('lon') lon: number,
    ) {
        return this.weatherService.getMarketWeather(Number(lat), Number(lon));
    }
}

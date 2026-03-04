import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { CropsService } from './crops.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Crops')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('crops')
export class CropsController {
    constructor(private readonly cropsService: CropsService) { }

    @Get()
    @ApiOperation({ summary: 'Get all crops catalog' })
    findAll() {
        return this.cropsService.findAllCrops();
    }

    @Get(':cropId/markets/:marketId/latest-price')
    @ApiOperation({ summary: 'Get latest recorded price for crop at market' })
    getLatestPrice(
        @Param('cropId') cropId: string,
        @Param('marketId') marketId: string
    ) {
        return this.cropsService.getLatestPrice(cropId, marketId);
    }

    @Get(':cropId/markets/:marketId/history')
    @ApiOperation({ summary: 'Get historical prices for trend charts (default 7 days)' })
    getHistory(
        @Param('cropId') cropId: string,
        @Param('marketId') marketId: string,
        @Query('days') days?: number
    ) {
        return this.cropsService.getHistoricalPrices(cropId, marketId, days || 7);
    }
}

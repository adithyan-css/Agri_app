import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Predictions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('predictions')
export class PredictionsController {
    constructor(private readonly predictionsService: PredictionsService) { }

    /**
     * GET /predictions/:cropId
     * Returns an AI-powered "Sell or Wait" recommendation card for a crop.
     * Compares current price against predicted future prices to advise the farmer.
     */
    @Get(':cropId')
    @ApiOperation({ summary: 'Get AI Sell or Wait recommendation for a crop' })
    @ApiQuery({ name: 'marketId', required: true, description: 'Market UUID to evaluate' })
    getRecommendation(
        @Param('cropId') cropId: string,
        @Query('marketId') marketId: string,
    ) {
        return this.predictionsService.getSellOrWaitRecommendation(cropId, marketId);
    }

    @Get(':cropId/markets/:marketId/forecast')
    @ApiOperation({ summary: 'Get smart AI prediction & recommendation for crop at a specific market' })
    getAiForecast(
        @Param('cropId') cropId: string,
        @Param('marketId') marketId: string
    ) {
        return this.predictionsService.getAiForecast(cropId, marketId);
    }
}

import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Predictions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('predictions')
export class PredictionsController {
    constructor(private readonly predictionsService: PredictionsService) { }

    @Get(':cropId/markets/:marketId/forecast')
    @ApiOperation({ summary: 'Get smart AI prediction & recommendation for crop at a specific market' })
    getAiForecast(
        @Param('cropId') cropId: string,
        @Param('marketId') marketId: string
    ) {
        return this.predictionsService.getAiForecast(cropId, marketId);
    }
}

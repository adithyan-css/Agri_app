import { Controller, Get, Param, UseGuards, UseInterceptors } from '@nestjs/common';
import { PredictionsService } from './predictions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

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

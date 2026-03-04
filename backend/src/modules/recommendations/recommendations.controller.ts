import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { RecommendationsService } from './recommendations.service';
import { TransportProfitDto } from './dto/transport-profit.dto';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Recommendations & Intelligence')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('intelligence')
export class RecommendationsController {
    constructor(private readonly recommendationsService: RecommendationsService) { }

    @Post('transport-profit')
    @ApiOperation({ summary: 'Calculate exact net profit factoring in market distance and transport costs' })
    calculateTransportProfit(@Body() dto: TransportProfitDto) {
        return this.recommendationsService.calculateTransportProfit(dto);
    }
}

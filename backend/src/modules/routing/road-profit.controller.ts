import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RoadProfitQueryDto } from './dto/road-profit-query.dto';
import { RoadProfitService } from './road-profit.service';

@ApiTags('Transport Profit')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('transport-profit')
export class RoadProfitController {
    constructor(private readonly roadProfitService: RoadProfitService) {}

    @Post()
    @ApiOperation({
        summary: 'Calculate transport profit using real road distances',
        description:
            'Finds nearby markets via PostGIS, calculates real road distance ' +
            'using OpenRouteService, fetches latest crop prices, and returns ' +
            'the top 5 most profitable markets sorted by net profit.',
    })
    @ApiResponse({ status: 200, description: 'Top 5 profitable markets with road distance details' })
    async calculate(@Body() dto: RoadProfitQueryDto) {
        return this.roadProfitService.findProfitableMarkets(dto);
    }
}

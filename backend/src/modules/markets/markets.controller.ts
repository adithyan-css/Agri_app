import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { MarketsService } from './markets.service';
import { NearbyMarketsDto } from './dto/nearby-markets.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Markets')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('markets')
export class MarketsController {
    constructor(private readonly marketsService: MarketsService) { }

    @Get()
    @ApiOperation({ summary: 'Get all active markets' })
    findAll() {
        return this.marketsService.findAll();
    }

    /**
     * GET /markets/nearby
     * Find the most profitable nearby markets within a given radius.
     * If cropId is provided, also returns price and profit_after_transport.
     */
    @Get('nearby')
    @ApiOperation({ summary: 'Find nearby markets with optional crop profit calculation (PostGIS)' })
    findNearby(@Query() query: NearbyMarketsDto) {
        // If cropId is given, return full profit analysis; otherwise just distances
        if (query.cropId) {
            return this.marketsService.findNearbyMarketsWithProfit(query);
        }
        return this.marketsService.findNearbyMarkets(query);
    }
}

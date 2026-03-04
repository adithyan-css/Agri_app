import { Controller, Get, Query, UseGuards, UseInterceptors } from '@nestjs/common';
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

    @Get('nearby')
    @ApiOperation({ summary: 'Find active markets near GPS coordinates (PostGIS)' })
    findNearby(@Query() query: NearbyMarketsDto) {
        return this.marketsService.findNearbyMarkets(query);
    }
}

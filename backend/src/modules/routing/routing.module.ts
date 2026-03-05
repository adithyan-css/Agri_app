import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RoutingService } from './routing.service';
import { RoadProfitService } from './road-profit.service';
import { RoadProfitController } from './road-profit.controller';
import { MarketsModule } from '../markets/markets.module';
import { CropsModule } from '../crops/crops.module';

@Module({
    imports: [ConfigModule, MarketsModule, CropsModule],
    controllers: [RoadProfitController],
    providers: [RoutingService, RoadProfitService],
    exports: [RoutingService],
})
export class RoutingModule {}

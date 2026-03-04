import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PredictionsController } from './predictions.controller';
import { PredictionsService } from './predictions.service';
import { Prediction } from './entities/prediction.entity';
import { Market } from '../markets/entities/market.entity';
import { CropsModule } from '../crops/crops.module';
import { WeatherModule } from '../weather/weather.module';
import { MarketsModule } from '../markets/markets.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Prediction, Market]),
        CropsModule,
        WeatherModule,
        MarketsModule
    ],
    controllers: [PredictionsController],
    providers: [PredictionsService],
    exports: [PredictionsService]
})
export class PredictionsModule { }

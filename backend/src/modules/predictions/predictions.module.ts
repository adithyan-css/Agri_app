import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PredictionsController } from './predictions.controller';
import { PredictionsService } from './predictions.service';
import { Prediction } from './entities/prediction.entity';
import { CropsModule } from '../crops/crops.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Prediction]),
        CropsModule
    ],
    controllers: [PredictionsController],
    providers: [PredictionsService],
    exports: [PredictionsService]
})
export class PredictionsModule { }

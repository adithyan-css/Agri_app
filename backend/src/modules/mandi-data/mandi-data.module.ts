import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Crop } from '../crops/entities/crop.entity';
import { CropPrice } from '../crops/entities/crop-price.entity';
import { Market } from '../markets/entities/market.entity';
import { MandiDataService } from './mandi-data.service';
import { MandiDataScheduler } from './mandi-data.scheduler';

@Module({
    imports: [TypeOrmModule.forFeature([Crop, CropPrice, Market])],
    providers: [MandiDataService, MandiDataScheduler],
    exports: [MandiDataService],
})
export class MandiDataModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SeedService } from './seed.service';
import { DataIngestionService } from './data-ingestion.service';
import { Crop } from '../crops/entities/crop.entity';
import { Market } from '../markets/entities/market.entity';
import { CropPrice } from '../crops/entities/crop-price.entity';

@Module({
    imports: [
        TypeOrmModule.forFeature([Crop, Market, CropPrice]),
    ],
    providers: [SeedService, DataIngestionService],
    exports: [SeedService, DataIngestionService],
})
export class SeedModule { }

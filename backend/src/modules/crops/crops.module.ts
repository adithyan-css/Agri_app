import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CropsController } from './crops.controller';
import { CropsService } from './crops.service';
import { Crop } from './entities/crop.entity';
import { CropPrice } from './entities/crop-price.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Crop, CropPrice])],
    controllers: [CropsController],
    providers: [CropsService],
    exports: [CropsService],
})
export class CropsModule { }

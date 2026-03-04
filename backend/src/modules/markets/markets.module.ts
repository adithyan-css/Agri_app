import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MarketsController } from './markets.controller';
import { MarketsService } from './markets.service';
import { Market } from './entities/market.entity';
import { CropsModule } from '../crops/crops.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Market]),
        CropsModule, // Needed for crop price lookups in profit optimizer
    ],
    controllers: [MarketsController],
    providers: [MarketsService],
    exports: [MarketsService]
})
export class MarketsModule { }

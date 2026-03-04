import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MarketsController } from './markets.controller';
import { MarketsService } from './markets.service';
import { Market } from './entities/market.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Market])],
    controllers: [MarketsController],
    providers: [MarketsService],
    exports: [MarketsService]
})
export class MarketsModule { }

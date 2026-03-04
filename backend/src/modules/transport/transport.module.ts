import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TransportService } from './transport.service';
import { TransportController } from './transport.controller';
import { Truck, Booking } from './entities/transport.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Truck, Booking])],
    controllers: [TransportController],
    providers: [TransportService],
    exports: [TransportService],
})
export class TransportModule { }

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AlertsService } from './alerts.service';
import { AlertsController } from './alerts.controller';
import { Alert } from './entities/alert.entity';
import { PriceMonitorService } from './price-monitor.service';
import { CropsModule } from '../crops/crops.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Alert]),
        CropsModule,
        NotificationsModule,
    ],
    controllers: [AlertsController],
    providers: [AlertsService, PriceMonitorService],
    exports: [AlertsService],
})
export class AlertsModule { }

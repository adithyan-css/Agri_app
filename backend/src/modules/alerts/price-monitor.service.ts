import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alert, AlertCondition } from './entities/alert.entity';
import { CropsService } from '../crops/crops.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class PriceMonitorService {
    private readonly logger = new Logger(PriceMonitorService.name);

    constructor(
        @InjectRepository(Alert)
        private readonly alertRepository: Repository<Alert>,
        private readonly cropsService: CropsService,
        private readonly notificationsService: NotificationsService,
    ) { }

    @Cron(CronExpression.EVERY_HOUR)
    async handlePriceCheck() {
        this.logger.log('Running scheduled price monitor check...');
        const activeAlerts = await this.alertRepository.find({
            where: { isActive: true },
            relations: ['crop'],
        });

        for (const alert of activeAlerts) {
            try {
                // Skip alerts with no market specified
                if (!alert.marketId) {
                    this.logger.debug(`Alert ${alert.id} has no market_id, skipping`);
                    continue;
                }
                // Fetch latest price for the crop at the specific market
                const latest = await this.cropsService.getLatestPrice(alert.cropId, alert.marketId);
                const currentPrice = Number(latest.pricePerKg);

                let triggered = false;
                if (alert.condition === AlertCondition.ABOVE && currentPrice >= alert.targetPrice) {
                    triggered = true;
                } else if (alert.condition === AlertCondition.BELOW && currentPrice <= alert.targetPrice) {
                    triggered = true;
                }

                if (triggered) {
                    this.logger.log(`Alert triggered for user ${alert.userId}: ${alert.crop.nameEn} is now ${currentPrice}`);
                    await this.notificationsService.sendNotification(
                        alert.userId,
                        'Price Alert!',
                        `${alert.crop.nameEn} has reached ₹${currentPrice}/kg, matching your threshold of ₹${alert.targetPrice}.`
                    );

                    // Mark alert as inactive to prevent spamming until user resets
                    await this.alertRepository.update(alert.id, { isActive: false });
                }
            } catch (err) {
                this.logger.error(`Failed to check alert ${alert.id}: ${err.message}`);
            }
        }
    }
}

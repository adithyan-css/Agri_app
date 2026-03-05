import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { MandiDataService } from './mandi-data.service';

@Injectable()
export class MandiDataScheduler {
    private readonly logger = new Logger(MandiDataScheduler.name);

    constructor(private readonly mandiDataService: MandiDataService) {}

    /** Runs every 6 hours to pull fresh mandi prices from data.gov.in. */
    @Cron('0 */6 * * *')
    async handleCron(): Promise<void> {
        this.logger.log('Scheduled mandi data ingestion triggered');
        try {
            const result = await this.mandiDataService.ingest();
            this.logger.log(
                `Cron result — inserted: ${result.inserted}, updated: ${result.updated}, ` +
                `skipped: ${result.skipped}, new markets: ${result.newMarkets}`,
            );
        } catch (err: any) {
            this.logger.error(`Cron ingestion failed: ${err.message}`, err.stack);
        }
    }
}

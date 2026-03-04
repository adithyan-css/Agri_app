import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alert, AlertCondition } from './entities/alert.entity';
import { CreateAlertDto } from './dto/create-alert.dto';

@Injectable()
export class AlertsService {
    constructor(
        @InjectRepository(Alert)
        private readonly alertRepository: Repository<Alert>,
    ) { }

    async createAlert(userId: string, dto: CreateAlertDto): Promise<any> {
        const alert = this.alertRepository.create({
            ...dto,
            userId,
        });
        const saved = await this.alertRepository.save(alert);
        // Reload with relations so we can return crop/market names
        return this.findOneWithRelations(saved.id);
    }

    async findByUser(userId: string): Promise<any[]> {
        const alerts = await this.alertRepository.find({
            where: { userId, isActive: true },
            relations: ['crop', 'market'],
            order: { createdAt: 'DESC' },
        });
        return alerts.map(a => this.toFlatJson(a));
    }

    async toggleAlert(id: string, userId: string, isActive: boolean): Promise<any> {
        const alert = await this.alertRepository.findOne({ where: { id, userId } });
        if (!alert) throw new NotFoundException('Alert not found');
        alert.isActive = isActive;
        await this.alertRepository.save(alert);
        return this.findOneWithRelations(id);
    }

    async deleteAlert(id: string, userId: string): Promise<void> {
        await this.alertRepository.update({ id, userId }, { isActive: false });
    }

    private async findOneWithRelations(id: string): Promise<any> {
        const alert = await this.alertRepository.findOne({
            where: { id },
            relations: ['crop', 'market'],
        });
        return alert ? this.toFlatJson(alert) : null;
    }

    private toFlatJson(alert: Alert): any {
        return {
            id: alert.id,
            cropId: alert.cropId,
            cropName: alert.crop?.nameEn ?? 'Unknown Crop',
            marketId: alert.marketId,
            marketName: alert.market?.nameEn ?? 'Unknown Market',
            targetPrice: alert.targetPrice,
            condition: alert.condition,
            isActive: alert.isActive,
            isTriggered: false,
            createdAt: alert.createdAt,
        };
    }
}

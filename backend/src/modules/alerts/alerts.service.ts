import { Injectable } from '@nestjs/common';
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

    async createAlert(userId: string, dto: CreateAlertDto): Promise<Alert> {
        const alert = this.alertRepository.create({
            ...dto,
            userId,
        });
        return this.alertRepository.save(alert);
    }

    async findByUser(userId: string): Promise<Alert[]> {
        return this.alertRepository.find({
            where: { userId, isActive: true },
            relations: ['crop'],
        });
    }

    async deleteAlert(id: string, userId: string): Promise<void> {
        await this.alertRepository.update({ id, userId }, { isActive: false });
    }
}

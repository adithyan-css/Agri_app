import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Crop } from '../../crops/entities/crop.entity';
import { Market } from '../../markets/entities/market.entity';
import { ApiProperty } from '@nestjs/swagger';

export enum AlertCondition {
    ABOVE = 'above',
    BELOW = 'below',
}

@Entity('alerts')
export class Alert {
    @ApiProperty({ example: 'a1111111-1111-1111-1111-111111111111' })
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ApiProperty({ example: 'u1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'user_id' })
    userId: string;

    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'crop_id' })
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'market_id' })
    marketId: string;

    @ApiProperty({ example: 50.00 })
    @Column({ name: 'target_price', type: 'decimal', precision: 10, scale: 2 })
    targetPrice: number;

    @ApiProperty({ enum: AlertCondition, example: AlertCondition.BELOW })
    @Column({ type: 'enum', enum: AlertCondition })
    condition: AlertCondition;

    @ApiProperty({ example: true })
    @Column({ name: 'is_active', default: true })
    isActive: boolean;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @ManyToOne(() => Crop)
    @JoinColumn({ name: 'crop_id' })
    crop: Crop;

    @ManyToOne(() => Market)
    @JoinColumn({ name: 'market_id' })
    market: Market;
}

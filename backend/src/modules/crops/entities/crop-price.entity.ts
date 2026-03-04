import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Crop } from './crop.entity';
import { ApiProperty } from '@nestjs/swagger';

@Entity('crop_prices')
export class CropPrice {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'crop_id' })
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'market_id' })
    marketId: string;

    @ApiProperty({ example: 45.00 })
    @Column({ name: 'price_per_kg', type: 'decimal', precision: 10, scale: 2 })
    pricePerKg: number;

    @ApiProperty({ example: '2024-03-01' })
    @Column({ name: 'record_date', type: 'date' })
    recordDate: Date;

    @ApiProperty({ example: 'A' })
    @Column({ name: 'quality_grade', default: 'A' })
    qualityGrade: string;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @ManyToOne(() => Crop)
    @JoinColumn({ name: 'crop_id' })
    crop: Crop;
}

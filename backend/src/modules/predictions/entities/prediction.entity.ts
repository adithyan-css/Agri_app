import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('predictions')
export class Prediction {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'crop_id' })
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @Column({ name: 'market_id' })
    marketId: string;

    @ApiProperty({ example: '2024-03-05' })
    @Column({ name: 'target_date', type: 'date' })
    targetDate: Date;

    @ApiProperty({ example: 46.50 })
    @Column({ name: 'predicted_price', type: 'decimal', precision: 10, scale: 2 })
    predictedPrice: number;

    @ApiProperty({ example: 0.85 })
    @Column({ name: 'confidence_score', type: 'decimal', precision: 5, scale: 4 })
    confidenceScore: number;

    @ApiProperty({ example: 42.00 })
    @Column({ name: 'lower_bound', type: 'decimal', precision: 10, scale: 2 })
    lowerBound: number;

    @ApiProperty({ example: 51.00 })
    @Column({ name: 'upper_bound', type: 'decimal', precision: 10, scale: 2 })
    upperBound: number;

    @ApiProperty({ example: 'chronos' })
    @Column({ name: 'model_used' })
    modelUsed: string;

    @CreateDateColumn({ name: 'generated_at' })
    generatedAt: Date;
}

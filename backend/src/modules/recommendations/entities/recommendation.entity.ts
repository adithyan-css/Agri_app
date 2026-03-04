import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('recommendations')
export class Recommendation {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    cropId: string;

    @Column()
    marketId: string;

    @Column({ nullable: true })
    userId: string;

    @Column({ type: 'varchar', length: 10 })
    action: string; // 'SELL' or 'WAIT'

    @Column({ type: 'varchar', length: 10 })
    trend: string; // 'UP', 'DOWN', 'STABLE'

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    currentPrice: number;

    @Column({ type: 'decimal', precision: 10, scale: 2 })
    predictedPrice: number;

    @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
    expectedProfit: number;

    @Column({ type: 'decimal', precision: 5, scale: 4, default: 0 })
    confidence: number;

    @Column({ type: 'text', nullable: true })
    reason: string;

    @CreateDateColumn()
    generatedAt: Date;
}
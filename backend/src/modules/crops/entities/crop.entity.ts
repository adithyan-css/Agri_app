import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('crops')
export class Crop {
    @ApiProperty({ example: 'c0000001-0001-4000-8000-000000000001' })
    @PrimaryColumn({ type: 'text' })
    id: string;

    @ApiProperty({ example: 'Tomato' })
    @Column({ name: 'name_en' })
    nameEn: string;

    @ApiProperty({ example: 'தக்காளி' })
    @Column({ name: 'name_ta' })
    nameTa: string;

    @ApiProperty({ example: 'Vegetable' })
    @Column({ nullable: true })
    category: string;

    @ApiProperty({ example: 'https://img.com/tomato.jpg' })
    @Column({ name: 'image_url', type: 'text', nullable: true })
    imageUrl: string;

    @ApiProperty({ example: 'kg' })
    @Column({ nullable: true })
    unit: string;

    @ApiProperty({ example: 7 })
    @Column({ name: 'base_shelf_life_days', nullable: true })
    baseShelfLifeDays: number;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;
}

import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('crops')
export class Crop {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @PrimaryGeneratedColumn('uuid')
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

    @ApiProperty({ example: 7 })
    @Column({ name: 'base_shelf_life_days', nullable: true })
    baseShelfLifeDays: number;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;
}

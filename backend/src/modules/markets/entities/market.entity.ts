import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity('markets')
export class Market {
    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ApiProperty({ example: 'Koyambedu Market' })
    @Column({ name: 'name_en' })
    nameEn: string;

    @ApiProperty({ example: 'கோயம்பேடு சந்தை' })
    @Column({ name: 'name_ta' })
    nameTa: string;

    @ApiProperty({ example: 'Chennai' })
    @Column()
    district: string;

    @ApiProperty({ example: 'Tamil Nadu' })
    @Column()
    state: string;

    // PostGIS location type. For simplicity in TypeORM mapping, we return it as GeoJSON coordinates
    // Or handle writes via raw queries to utilize ST_SetSRID(ST_MakePoint)
    @Column({ type: 'geometry', spatialFeatureType: 'Point', srid: 4326, select: false })
    location: any;

    // Virtual distances used during spatial queries
    @ApiProperty({ example: 12.5 })
    distanceKm?: number;

    @ApiProperty({ example: true })
    @Column({ name: 'is_active', default: true })
    isActive: boolean;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;
}

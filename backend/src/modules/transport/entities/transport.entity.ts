import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ApiProperty } from '@nestjs/swagger';

@Entity('trucks')
export class Truck {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ApiProperty({ example: 'TN-38-AX-1234' })
    @Column()
    licensePlate: string;

    @ApiProperty({ example: 'Arun Kumar' })
    @Column()
    driverName: string;

    @ApiProperty({ example: '9876543210' })
    @Column()
    driverPhone: string;

    @ApiProperty({ example: 5000 })
    @Column({ type: 'int' })
    capacityKg: number;

    @ApiProperty({ example: 15.0 })
    @Column({ type: 'decimal', precision: 10, scale: 2 })
    perKmRate: number;

    @ApiProperty({ example: true })
    @Column({ default: true })
    isAvailable: boolean;

    @Column({
        type: 'geography',
        spatialFeatureType: 'Point',
        srid: 4326,
        nullable: true,
    })
    currentLocation: string;
}

@Entity('bookings')
export class Booking {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ name: 'user_id' })
    userId: string;

    @Column({ name: 'truck_id' })
    truckId: string;

    @Column({ type: 'date' })
    bookingDate: Date;

    @Column({ default: 'pending' })
    status: string; // pending, confirmed, completed, cancelled

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @ManyToOne(() => Truck)
    @JoinColumn({ name: 'truck_id' })
    truck: Truck;
}

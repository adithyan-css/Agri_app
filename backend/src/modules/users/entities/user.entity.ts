import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum UserRole {
    FARMER = 'farmer',
    ADMIN = 'admin',
}

@Entity('users')
export class User {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true, nullable: true })
    firebaseUid: string;

    @Column({ unique: true })
    phoneNumber: string;

    @Column({ nullable: true })
    name: string;

    @Column({ type: 'enum', enum: UserRole, default: UserRole.FARMER })
    role: UserRole;

    @Column({ default: false })
    isVerified: boolean;

    @Column({ nullable: true })
    preferredLanguage: string; // e.g., 'en', 'ta'

    @Column({ nullable: true })
    fcmToken: string;

    @Column({ type: 'float', nullable: true })
    lat: number;

    @Column({ type: 'float', nullable: true })
    lng: number;

    @Column({ name: 'preferred_market_id', type: 'text', nullable: true })
    preferredMarketId: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}

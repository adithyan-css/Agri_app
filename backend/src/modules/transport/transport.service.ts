import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Truck, Booking } from './entities/transport.entity';
import { CreateBookingDto } from './dto/create-booking.dto';

@Injectable()
export class TransportService {
    constructor(
        @InjectRepository(Truck)
        private readonly truckRepository: Repository<Truck>,
        @InjectRepository(Booking)
        private readonly bookingRepository: Repository<Booking>,
    ) { }

    async findAllAvailable(): Promise<Truck[]> {
        return this.truckRepository.find({
            where: { isAvailable: true },
        });
    }

    async bookTruck(userId: string, dto: CreateBookingDto): Promise<Booking> {
        const truck = await this.truckRepository.findOne({
            where: { id: dto.truckId, isAvailable: true },
        });

        if (!truck) {
            throw new NotFoundException('Truck not available for booking');
        }

        const booking = this.bookingRepository.create({
            userId,
            truckId: dto.truckId,
            bookingDate: new Date(dto.bookingDate),
            status: 'confirmed',
        });

        // Mark truck as unavailable for now (simplified logic)
        truck.isAvailable = false;
        await this.truckRepository.save(truck);

        return this.bookingRepository.save(booking);
    }

    async getUserBookings(userId: string): Promise<Booking[]> {
        return this.bookingRepository.find({
            where: { userId },
            relations: ['truck'],
            order: { bookingDate: 'DESC' },
        });
    }
}

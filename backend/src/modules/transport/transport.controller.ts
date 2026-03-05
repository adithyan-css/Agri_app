import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { TransportService } from './transport.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from '../users/users.service';

@ApiTags('Transport')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('transport')
export class TransportController {
    constructor(
        private readonly transportService: TransportService,
        private readonly usersService: UsersService,
    ) { }

    /** Resolve the internal DB user ID from the Firebase UID on the request. */
    private async getUserId(req: any): Promise<string> {
        const firebaseUid = req.user?.uid;
        if (!firebaseUid) throw new Error('No Firebase UID on request');
        const user = await this.usersService.findByFirebaseUid(firebaseUid);
        if (!user) {
            const created = await this.usersService.create({
                firebaseUid,
                phoneNumber: req.user.phoneNumber || `firebase_${firebaseUid}`,
                name: req.user.name || req.user.email || 'User',
            });
            return created.id;
        }
        return user.id;
    }

    @Get('available')
    @ApiOperation({ summary: 'Get all available trucks for booking' })
    findAllAvailable() {
        return this.transportService.findAllAvailable();
    }

    @Post('book')
    @ApiOperation({ summary: 'Book a truck' })
    async bookTruck(@Request() req, @Body() dto: CreateBookingDto) {
        const userId = await this.getUserId(req);
        return this.transportService.bookTruck(userId, dto);
    }

    @Get('my-bookings')
    @ApiOperation({ summary: 'Get current user bookings' })
    async getMyBookings(@Request() req) {
        const userId = await this.getUserId(req);
        return this.transportService.getUserBookings(userId);
    }
}

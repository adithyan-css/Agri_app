import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { TransportService } from './transport.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Transport')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('transport')
export class TransportController {
    constructor(private readonly transportService: TransportService) { }

    @Get('available')
    @ApiOperation({ summary: 'Get all available trucks for booking' })
    findAllAvailable() {
        return this.transportService.findAllAvailable();
    }

    @Post('book')
    @ApiOperation({ summary: 'Book a truck' })
    bookTruck(@Request() req, @Body() dto: CreateBookingDto) {
        return this.transportService.bookTruck(req.user.id, dto);
    }

    @Get('my-bookings')
    @ApiOperation({ summary: 'Get current user bookings' })
    getMyBookings(@Request() req) {
        return this.transportService.getUserBookings(req.user.id);
    }
}

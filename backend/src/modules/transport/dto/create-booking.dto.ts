import { IsString, IsDateString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateBookingDto {
    @ApiProperty({ example: 't1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    truckId: string;

    @ApiProperty({ example: '2024-03-10' })
    @IsDateString()
    @IsNotEmpty()
    bookingDate: string;
}

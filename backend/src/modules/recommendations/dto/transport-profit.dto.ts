import { IsNumber, IsNotEmpty, IsString, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class TransportProfitDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    targetMarketId: string;

    @ApiProperty({ example: 12.5, description: 'Distance to market in KM' })
    @IsNumber()
    @Min(0)
    distanceKm: number;

    @ApiProperty({ example: 1000, description: 'Total volume in Kg' })
    @IsNumber()
    @Min(1)
    volumeKg: number;

    @ApiProperty({ example: 15, description: 'Transport rate per KM in ₹' })
    @IsNumber()
    @Min(0)
    perKmRate: number;
}

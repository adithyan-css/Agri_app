import { IsNumber, IsOptional, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class NearbyMarketsDto {
    @ApiProperty({ example: 80.1913 })
    @IsNumber()
    @Min(-180)
    @Max(180)
    lng: number;

    @ApiProperty({ example: 13.0674 })
    @IsNumber()
    @Min(-90)
    @Max(90)
    lat: number;

    @ApiProperty({ example: 50, required: false, description: 'Search radius in kilometers' })
    @IsOptional()
    @IsNumber()
    radiusKm?: number = 50;
}

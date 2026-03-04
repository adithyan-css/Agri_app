import { IsNumber, IsOptional, IsUUID, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class NearbyMarketsDto {
    @ApiProperty({ example: 80.1913 })
    @Type(() => Number)
    @IsNumber()
    @Min(-180)
    @Max(180)
    lng: number;

    @ApiProperty({ example: 13.0674 })
    @Type(() => Number)
    @IsNumber()
    @Min(-90)
    @Max(90)
    lat: number;

    @ApiProperty({ example: 50, required: false, description: 'Search radius in kilometers' })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    radiusKm?: number = 50;

    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111', required: false, description: 'Crop UUID to calculate prices & profit' })
    @IsOptional()
    @IsUUID()
    cropId?: string;
}

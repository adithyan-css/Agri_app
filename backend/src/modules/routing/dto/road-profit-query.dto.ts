import { IsNumber, IsString, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class RoadProfitQueryDto {
    @ApiProperty({ example: 80.1913, description: 'Farmer longitude' })
    @Type(() => Number)
    @IsNumber()
    @Min(-180)
    @Max(180)
    farmerLng: number;

    @ApiProperty({ example: 13.0674, description: 'Farmer latitude' })
    @Type(() => Number)
    @IsNumber()
    @Min(-90)
    @Max(90)
    farmerLat: number;

    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111', description: 'Crop to sell' })
    @IsString()
    cropId: string;

    @ApiProperty({ example: 500, description: 'Quantity in kg' })
    @Type(() => Number)
    @IsNumber()
    @Min(1)
    quantity: number;

    @ApiPropertyOptional({ example: 100, description: 'Search radius in km (default 100)' })
    @IsOptional()
    @Type(() => Number)
    @IsNumber()
    @Min(1)
    radiusKm?: number = 100;
}

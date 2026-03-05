import { IsString, IsNumber, IsDateString, IsOptional, IsNotEmpty, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCropPriceDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    marketId: string;

    @ApiProperty({ example: 45.50 })
    @IsNumber()
    @Min(0)
    pricePerKg: number;

    @ApiProperty({ example: '2024-03-10' })
    @IsDateString()
    recordDate: string;

    @ApiPropertyOptional({ example: 'A', description: 'Quality grade: A, B, or C' })
    @IsOptional()
    @IsString()
    qualityGrade?: string;
}

import { IsString, IsNotEmpty, IsNumber, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMarketDto {
    @ApiProperty({ example: 'Koyambedu Wholesale Market' })
    @IsString()
    @IsNotEmpty()
    nameEn: string;

    @ApiProperty({ example: 'கோயம்பேடு மொத்த சந்தை' })
    @IsString()
    @IsNotEmpty()
    nameTa: string;

    @ApiProperty({ example: 'Chennai' })
    @IsString()
    @IsNotEmpty()
    district: string;

    @ApiProperty({ example: 'Tamil Nadu' })
    @IsString()
    @IsNotEmpty()
    state: string;

    @ApiProperty({ example: 13.0827 })
    @IsNumber()
    lat: number;

    @ApiProperty({ example: 80.2707 })
    @IsNumber()
    lon: number;

    @ApiPropertyOptional({ example: true })
    @IsOptional()
    @IsBoolean()
    isActive?: boolean;
}

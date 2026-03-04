import { IsUUID, IsNotEmpty, IsOptional, IsString, IsArray, ValidateNested, IsNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

class HistoricalDataPoint {
    @ApiProperty({ example: '2024-03-01' })
    @IsString()
    date: string;

    @ApiProperty({ example: 45.5 })
    @IsNumber()
    price: number;
}

class WeatherForecast {
    @ApiProperty({ example: 31.5 })
    @IsNumber()
    temp: number;

    @ApiProperty({ example: 0 })
    @IsNumber()
    rainfall: number;

    @ApiProperty({ example: 65 })
    @IsNumber()
    humidity: number;

    @ApiProperty({ example: 'Clear' })
    @IsString()
    conditions: string;
}

export class PredictionRequestDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsUUID()
    @IsNotEmpty()
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsUUID()
    @IsNotEmpty()
    marketId: string;

    @ApiPropertyOptional({ example: 'chronos' })
    @IsOptional()
    @IsString()
    useModel?: string;

    @ApiPropertyOptional({ type: [HistoricalDataPoint] })
    @IsOptional()
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => HistoricalDataPoint)
    historicalData?: HistoricalDataPoint[];

    @ApiPropertyOptional({ type: WeatherForecast })
    @IsOptional()
    @ValidateNested()
    @Type(() => WeatherForecast)
    weatherForecast?: WeatherForecast;
}

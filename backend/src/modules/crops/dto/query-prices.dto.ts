import { IsString, IsOptional, IsInt, Min, Max } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class QueryPricesDto {
    @ApiPropertyOptional({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsOptional()
    @IsString()
    cropId?: string;

    @ApiPropertyOptional({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsOptional()
    @IsString()
    marketId?: string;

    @ApiPropertyOptional({ example: 7, description: 'Number of days of history to return' })
    @IsOptional()
    @Type(() => Number)
    @IsInt()
    @Min(1)
    @Max(365)
    days?: number;
}

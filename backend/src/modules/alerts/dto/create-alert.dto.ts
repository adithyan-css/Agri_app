import { IsString, IsNumber, IsEnum, IsOptional, IsNotEmpty } from 'class-validator';
import { AlertCondition } from '../entities/alert.entity';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAlertDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    cropId: string;

    @ApiPropertyOptional({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsOptional()
    @IsString()
    marketId?: string;

    @ApiProperty({ example: 45.50 })
    @IsNumber()
    targetPrice: number;

    @ApiProperty({ enum: AlertCondition, example: AlertCondition.BELOW })
    @IsEnum(AlertCondition)
    condition: AlertCondition;
}

import { IsBoolean, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { AlertCondition } from '../entities/alert.entity';

export class UpdateAlertDto {
    @ApiPropertyOptional({ example: 50.00 })
    @IsOptional()
    @IsNumber()
    targetPrice?: number;

    @ApiPropertyOptional({ enum: AlertCondition })
    @IsOptional()
    @IsEnum(AlertCondition)
    condition?: AlertCondition;

    @ApiPropertyOptional({ example: false })
    @IsOptional()
    @IsBoolean()
    isActive?: boolean;
}

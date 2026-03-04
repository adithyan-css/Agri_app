import { IsUUID, IsNumber, IsEnum, IsBoolean } from 'class-validator';
import { AlertCondition } from '../entities/alert.entity';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAlertDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsUUID()
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsUUID()
    marketId: string;

    @ApiProperty({ example: 45.50 })
    @IsNumber()
    targetPrice: number;

    @ApiProperty({ enum: AlertCondition, example: AlertCondition.BELOW })
    @IsEnum(AlertCondition)
    condition: AlertCondition;
}

import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SendNotificationDto {
    @ApiProperty({ example: 'u1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    userId: string;

    @ApiProperty({ example: 'Price Alert Triggered!' })
    @IsString()
    @IsNotEmpty()
    title: string;

    @ApiProperty({ example: 'Tomato has reached ₹45.50/kg' })
    @IsString()
    @IsNotEmpty()
    body: string;

    @ApiPropertyOptional({ example: { type: 'price_alert', cropName: 'Tomato' } })
    @IsOptional()
    data?: Record<string, string>;
}

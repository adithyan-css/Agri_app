import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDto {
    @ApiProperty({ example: '+919876543210', description: 'Phone number with country code' })
    @IsString()
    @IsNotEmpty()
    phoneNumber: string;

    @ApiPropertyOptional({ example: 'Kumar', description: 'User display name' })
    @IsString()
    @IsOptional()
    name?: string;

    @ApiPropertyOptional({ example: 'en', description: 'Preferred language code (en or ta)' })
    @IsString()
    @IsOptional()
    preferredLanguage?: string;
}
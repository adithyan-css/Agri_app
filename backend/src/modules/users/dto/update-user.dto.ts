import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole } from '../entities/user.entity';

export class UpdateUserDto {
    @ApiPropertyOptional({ example: 'Ramu K' })
    @IsOptional()
    @IsString()
    name?: string;

    @ApiPropertyOptional({ example: 'ta' })
    @IsOptional()
    @IsString()
    preferredLanguage?: string;

    @ApiPropertyOptional({ example: 13.08 })
    @IsOptional()
    @IsNumber()
    lat?: number;

    @ApiPropertyOptional({ example: 80.27 })
    @IsOptional()
    @IsNumber()
    lng?: number;

    @ApiPropertyOptional({ enum: UserRole })
    @IsOptional()
    @IsEnum(UserRole)
    role?: UserRole;
}

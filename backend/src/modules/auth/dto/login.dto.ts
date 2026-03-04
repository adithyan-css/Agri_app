import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
    @ApiProperty({ example: '+919876543210' })
    @IsString()
    @IsNotEmpty()
    phoneNumber: string;
}

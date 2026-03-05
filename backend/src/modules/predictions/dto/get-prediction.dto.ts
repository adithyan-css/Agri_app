import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GetPredictionDto {
    @ApiProperty({ example: 'c1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    cropId: string;

    @ApiProperty({ example: 'm1111111-1111-1111-1111-111111111111' })
    @IsString()
    @IsNotEmpty()
    marketId: string;
}

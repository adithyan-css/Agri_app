import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MlServiceService } from './ml-service.service';

@Module({
    imports: [ConfigModule],
    providers: [MlServiceService],
    exports: [MlServiceService],
})
export class MlServiceModule { }
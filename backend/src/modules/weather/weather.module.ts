import { Module } from '@nestjs/common';
import { WeatherService } from './weather.service';
import { ConfigModule } from '@nestjs/config';

@Module({
    imports: [ConfigModule],
    providers: [WeatherService],
    exports: [WeatherService],
})
export class WeatherModule { }

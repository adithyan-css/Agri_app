import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
//import { RedisModule } from 'nestjs-redis';
import { databaseConfig } from './config/database.config';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { CropsModule } from './modules/crops/crops.module';
import { MarketsModule } from './modules/markets/markets.module';
import { PredictionsModule } from './modules/predictions/predictions.module';
import { RecommendationsModule } from './modules/recommendations/recommendations.module';
import { WeatherModule } from './modules/weather/weather.module';

@Module({
    imports: [
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),
        TypeOrmModule.forRootAsync({
            imports: [ConfigModule],
            useFactory: (configService: ConfigService) => databaseConfig(configService),
            inject: [ConfigService],
        }),
        // RedisModule.forRootAsync({
        //   imports: [ConfigModule],
        // useFactory: (configService: ConfigService) => ({
        //   url: configService.get<string>('REDIS_URL', 'redis://localhost:6379'),
        //}),
        //inject: [ConfigService],
        //}),
        UsersModule,
        AuthModule,
        CropsModule,
        MarketsModule,
        PredictionsModule,
        RecommendationsModule,
        WeatherModule
    ],
    controllers: [],
    providers: [],
})
export class AppModule { }

import { ConfigService } from '@nestjs/config';

export const redisConfig = (configService: ConfigService) => ({
    url: configService.get<string>('REDIS_URL', 'redis://localhost:6379'),
});

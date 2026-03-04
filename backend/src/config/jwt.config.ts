import { ConfigService } from '@nestjs/config';

export const jwtConfig = (configService: ConfigService) => ({
    secret: configService.get<string>('JWT_SECRET', 'agriprice-dev-secret-key'),
    signOptions: {
        expiresIn: configService.get<string>('JWT_EXPIRATION', '7d'),
    },
});

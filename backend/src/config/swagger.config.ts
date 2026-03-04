import { DocumentBuilder } from '@nestjs/swagger';

export const swaggerConfig = new DocumentBuilder()
    .setTitle('AgriPrice AI API')
    .setDescription('The backend API for the AgriPrice AI mobile platform')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

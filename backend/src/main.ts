import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { initializeFirebaseAdmin } from './config/firebase-admin.config';

async function bootstrap() {
    // Initialize Firebase Admin SDK before creating the app
    initializeFirebaseAdmin();

    const app = await NestFactory.create(AppModule);

    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

    const config = new DocumentBuilder()
        .setTitle('AgriPrice AI API')
        .setDescription('The backend API for the AgriPrice AI mobile platform')
        .setVersion('1.0')
        .addBearerAuth()
        .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);

    app.enableCors();

    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`Application is running on: http://localhost:${port}/api/v1`);
}
bootstrap();

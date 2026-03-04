// NestJS built-in ValidationPipe is used globally in main.ts.
// This file provides a custom configuration if additional logic is needed.
import { ValidationPipe, BadRequestException } from '@nestjs/common';

export const customValidationPipe = new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
    exceptionFactory: (errors) => {
        const messages = errors.map((err) => {
            const constraints = Object.values(err.constraints || {});
            return `${err.property}: ${constraints.join(', ')}`;
        });
        return new BadRequestException(messages);
    },
});

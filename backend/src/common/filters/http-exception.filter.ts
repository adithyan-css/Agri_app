import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response, Request } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
    private readonly logger = new Logger(HttpExceptionFilter.name);

    catch(exception: HttpException, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();
        const status = exception.getStatus?.() ?? HttpStatus.INTERNAL_SERVER_ERROR;
        const exceptionResponse = exception.getResponse();

        const errorBody = {
            statusCode: status,
            timestamp: new Date().toISOString(),
            path: request.url,
            message: typeof exceptionResponse === 'string'
                ? exceptionResponse
                : (exceptionResponse as any).message || exception.message,
        };

        this.logger.error(`${request.method} ${request.url} ${status}`, JSON.stringify(errorBody));

        response.status(status).json(errorBody);
    }
}

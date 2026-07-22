import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { randomUUID } from 'crypto';

export class AppError extends Error {
  constructor(
    public readonly code: string,
    public readonly status: number = HttpStatus.BAD_REQUEST,
    public readonly details?: unknown,
  ) {
    super(code);
  }
}

@Catch()
export class SanitizedExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request & { correlationId?: string }>();
    const correlationId = request.correlationId ?? randomUUID();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_ERROR';
    let details: unknown;

    if (exception instanceof AppError) {
      status = exception.status;
      code = exception.code;
      details = exception.details;
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();
      if (typeof body === 'object' && body && 'message' in body) {
        code =
          status === HttpStatus.BAD_REQUEST ? 'VALIDATION_ERROR' : 'HTTP_ERROR';
        details = (body as { message?: unknown }).message;
      } else {
        code = 'HTTP_ERROR';
      }
    } else if (exception instanceof Error) {
      // Keep diagnostics local and sanitized — never leak stacks to clients.

      console.error(`[auth] ${exception.name}: ${exception.message}`);
    } else {
      console.error('[auth] non-error exception');
    }

    response.status(status).json({
      code,
      message: 'Request failed',
      correlationId,
      ...(details !== undefined ? { details } : {}),
    });
  }
}

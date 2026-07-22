import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
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

/** Keep only field names / constraint codes — never secret values. */
export function sanitizeErrorDetails(details: unknown): unknown {
  if (details === undefined || details === null) {
    return undefined;
  }
  if (Array.isArray(details)) {
    return details.map((item) => sanitizeDetailItem(item)).filter(Boolean);
  }
  return sanitizeDetailItem(details);
}

function sanitizeDetailItem(item: unknown): unknown {
  if (typeof item === 'string') {
    // class-validator style: "<property> must ..." — keep the property token only.
    const property = item.trim().split(/\s+/)[0];
    return property || 'invalid';
  }
  if (item && typeof item === 'object') {
    const record = item as {
      property?: unknown;
      constraints?: Record<string, unknown>;
      code?: unknown;
    };
    if (typeof record.property === 'string') {
      return {
        property: record.property,
        ...(record.constraints
          ? { constraints: Object.keys(record.constraints) }
          : {}),
      };
    }
    if (typeof record.code === 'string') {
      return { code: record.code };
    }
  }
  return 'invalid';
}

@Catch()
export class SanitizedExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(SanitizedExceptionFilter.name);

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
      details = sanitizeErrorDetails(exception.details);
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      const body = exception.getResponse();
      if (typeof body === 'object' && body && 'message' in body) {
        code =
          status === HttpStatus.BAD_REQUEST ? 'VALIDATION_ERROR' : 'HTTP_ERROR';
        details = sanitizeErrorDetails((body as { message?: unknown }).message);
      } else {
        code = 'HTTP_ERROR';
      }
    } else if (exception instanceof Error) {
      // Never log exception.message, URLs, or bodies — correlation + category only.
      this.logger.error({
        correlationId,
        code,
        category: exception.name,
      });
    } else {
      this.logger.error({
        correlationId,
        code,
        category: 'non_error',
      });
    }

    const payload: Record<string, unknown> = {
      code,
      message: 'Request failed',
      correlationId,
    };
    if (details !== undefined) {
      payload.details = details;
    }

    response.status(status).json(payload);
  }
}

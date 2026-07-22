import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { randomUUID } from 'crypto';
import { AppModule } from './app.module';
import { SanitizedExceptionFilter } from './common/errors/app-error';
import type { NextFunction, Request, Response } from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { rawBody: false });
  const config = app.get(ConfigService);
  const env = config.get<string>('APP_ENVIRONMENT') ?? 'dev';

  app.use(helmet());
  app.setGlobalPrefix('v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useGlobalFilters(new SanitizedExceptionFilter());
  app.use((req: Request & { correlationId?: string }, res: Response, next: NextFunction) => {
    const correlationId = randomUUID();
    req.correlationId = correlationId;
    res.setHeader('x-correlation-id', correlationId);
    next();
  });

  const cors = config.get<string>('CORS_ORIGINS') ?? '';
  if (cors === '*') {
    app.enableCors({ origin: true });
  } else if (cors.trim()) {
    app.enableCors({ origin: cors.split(',').map((v) => v.trim()) });
  }

  if (env !== 'prod') {
    const swagger = new DocumentBuilder()
      .setTitle('Laforika Auth API')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, swagger);
    SwaggerModule.setup('docs', app, document);
  }

  const port = config.get<number>('PORT') ?? 3000;
  await app.listen(port);
}

bootstrap();

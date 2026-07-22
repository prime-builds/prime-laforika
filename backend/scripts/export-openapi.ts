import { writeFileSync, mkdirSync } from 'fs';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from '../src/app.module';

async function main() {
  const app = await NestFactory.create(AppModule, { logger: false });
  const config = new DocumentBuilder()
    .setTitle('Laforika Auth API')
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  mkdirSync('openapi', { recursive: true });
  writeFileSync(
    'openapi/openapi.json',
    `${JSON.stringify(document, null, 2)}\n`,
  );
  await app.close();
}

main().catch((error) => {
  console.error('openapi export failed');
  process.exitCode = 1;
  throw error;
});

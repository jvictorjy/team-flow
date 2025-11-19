import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter } from '@nestjs/platform-fastify';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import 'reflect-metadata';

import { AppModule } from './app.module';

const PORT = Number(process.env.PORT || 3001);
const ORIGINS = (process.env.CORS_ORIGINS || 'http://localhost:5173,http://localhost:3000').split(
  ',',
);

async function bootstrap() {
  const app = await NestFactory.create(AppModule, new FastifyAdapter({ logger: true }));

  // Fastify plugins
  const fastify = app.getHttpAdapter().getInstance();
  await fastify.register(require('@fastify/cors'), { origin: ORIGINS, credentials: true });
  await fastify.register(require('@fastify/helmet'));

  // Validação global
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }));

  // Swagger
  const config = new DocumentBuilder().setTitle('TeamFlow Auth').setVersion('0.1.0').build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  await app.listen(PORT, '0.0.0.0');
}

bootstrap();

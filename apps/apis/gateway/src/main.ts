import { NestFactory } from '@nestjs/core';
import { FastifyAdapter } from '@nestjs/platform-fastify';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

import 'reflect-metadata';

import { AppModule } from './app.module';

const PORT = Number(process.env.PORT || 3000);
const ORIGINS = (process.env.CORS_ORIGINS || 'http://localhost:5173,http://localhost:3000').split(
  ',',
);

async function bootstrap() {
  const app = await NestFactory.create(AppModule, new FastifyAdapter({ logger: true }));

  // Registrar plugins no Fastify subjacente
  const fastify = app.getHttpAdapter().getInstance();
  await fastify.register(require('@fastify/cors'), { origin: ORIGINS, credentials: true });
  await fastify.register(require('@fastify/helmet'));
  await fastify.register(require('@fastify/rate-limit'), { max: 100, timeWindow: '1 minute' });

  // Swagger / OpenAPI
  const config = new DocumentBuilder()
    .setTitle('TeamFlow Gateway')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  await app.listen(PORT, '0.0.0.0');
}

bootstrap();

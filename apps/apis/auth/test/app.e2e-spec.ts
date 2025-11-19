import { INestApplication } from '@nestjs/common';
import { ValidationPipe } from '@nestjs/common';
import { FastifyAdapter } from '@nestjs/platform-fastify';
import { Test, TestingModule } from '@nestjs/testing';

import request from 'supertest';

import { AppModule } from '../src/app.module';

describe('AuthController (e2e)', () => {
  let app: INestApplication;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication(new FastifyAdapter());
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true }));

    await app.init();
    await app.getHttpAdapter().getInstance().ready();
  });

  afterEach(async () => {
    await app.close();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer()).get('/').expect(200).expect({
      name: 'TeamFlow Auth',
      version: '0.1.0',
    });
  });

  it('/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .then((response) => {
        expect(response.body).toHaveProperty('status', 'ok');
        expect(response.body).toHaveProperty('service', 'auth');
        expect(response.body).toHaveProperty('time');
      });
  });

  describe('/auth/login (POST)', () => {
    it('should return tokens for valid credentials', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'password123',
        })
        .expect(201)
        .then((response) => {
          expect(response.body).toHaveProperty('accessToken');
          expect(response.body).toHaveProperty('refreshToken');
          expect(response.body).toHaveProperty('email', 'test@example.com');
        });
    });

    it('should validate email format', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'invalid-email',
          password: 'password123',
        })
        .expect(400);
    });

    it('should validate password length', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'short',
        })
        .expect(400);
    });

    it('should reject request without email', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          password: 'password123',
        })
        .expect(400);
    });

    it('should reject request without password', () => {
      return request(app.getHttpServer())
        .post('/auth/login')
        .send({
          email: 'test@example.com',
        })
        .expect(400);
    });
  });
});

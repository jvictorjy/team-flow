import { Test, TestingModule } from '@nestjs/testing';

import { AuthController } from './auth.controller';

describe('AuthController', () => {
  let controller: AuthController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('health', () => {
    it('should return health status', () => {
      const result = controller.health();

      expect(result).toHaveProperty('status', 'ok');
      expect(result).toHaveProperty('service', 'auth');
      expect(result).toHaveProperty('time');
      expect(typeof result.time).toBe('string');
    });
  });

  describe('root', () => {
    it('should return service information', () => {
      const result = controller.root();

      expect(result).toEqual({
        name: 'TeamFlow Auth',
        version: '0.1.0',
      });
    });
  });

  describe('login', () => {
    it('should return stub tokens', async () => {
      const loginDto = {
        email: 'test@example.com',
        password: 'password123',
      };

      const result = await controller.login(loginDto);

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result).toHaveProperty('email', loginDto.email);
      expect(result.accessToken).toBe('stub.access.token');
      expect(result.refreshToken).toBe('stub.refresh.token');
    });
  });
});

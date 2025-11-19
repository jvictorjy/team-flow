import { Test, TestingModule } from '@nestjs/testing';

import { AppController } from './app.controller';

describe('AppController', () => {
  let controller: AppController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    controller = module.get<AppController>(AppController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('health', () => {
    it('should return health status', () => {
      const result = controller.health();

      expect(result).toHaveProperty('status', 'ok');
      expect(result).toHaveProperty('service', 'gateway');
      expect(result).toHaveProperty('time');
      expect(typeof result.time).toBe('string');
    });
  });

  describe('root', () => {
    it('should return service information', () => {
      const result = controller.root();

      expect(result).toEqual({
        name: 'TeamFlow Gateway',
        version: '0.1.0',
      });
    });
  });
});

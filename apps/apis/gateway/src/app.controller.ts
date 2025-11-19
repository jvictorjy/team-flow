import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get('/health')
  health() {
    return { status: 'ok', service: 'gateway', time: new Date().toISOString() };
  }

  @Get('/')
  root() {
    return { name: 'TeamFlow Gateway', version: '0.1.0' };
  }
}

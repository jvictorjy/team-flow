import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiBody, ApiOperation, ApiTags } from '@nestjs/swagger';

import { LoginDto } from './dto/login.dto';

@ApiTags('auth')
@Controller()
export class AuthController {
  @Get('/health')
  health() {
    return { status: 'ok', service: 'auth', time: new Date().toISOString() };
  }

  @Get('/')
  root() {
    return { name: 'TeamFlow Auth', version: '0.1.0' };
  }

  @Post('/auth/login')
  @ApiOperation({ summary: 'User login' })
  @ApiBody({ type: LoginDto })
  async login(@Body() dto: LoginDto) {
    // Stub: aqui você faria validação de credenciais e emissão de tokens
    return {
      accessToken: 'stub.access.token',
      refreshToken: 'stub.refresh.token',
      email: dto.email,
    };
  }
}

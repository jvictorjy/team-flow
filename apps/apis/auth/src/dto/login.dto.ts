import { ApiProperty } from '@nestjs/swagger';

import { IsEmail, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: 'user@example.com', description: 'User email address' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'password123', minLength: 8, description: 'User password' })
  @MinLength(8)
  password!: string;
}

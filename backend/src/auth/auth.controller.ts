import { Controller, Post, UseGuards, Request  } from '@nestjs/common';
import { LocalAuthGuard } from './local-auth.guard.js';
import type { AuthenticatedRequest } from './types/authenticated.js';


@Controller('auth')
export class AuthController {
  @UseGuards(LocalAuthGuard)
  @Post('login')

  async login(@Request() req: AuthenticatedRequest) {
    return req.user;
  }
}
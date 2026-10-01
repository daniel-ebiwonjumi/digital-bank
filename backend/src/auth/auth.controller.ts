import { Controller, Post, UseGuards, Request  } from '@nestjs/common';
import { LocalAuthGuard } from './auth.guard.js';
import type { AuthenticatedRequest } from './types/authenticated.js';
import { FastifyRequest } from 'fastify';


@Controller('auth')
export class AuthController {
  @UseGuards(LocalAuthGuard)
  @Post('login')
  async login(@Request() req: AuthenticatedRequest) {
    return req.user;
  }

}
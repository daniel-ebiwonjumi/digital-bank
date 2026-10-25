import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service.js';
import * as argon2 from 'argon2';
import { JwtService } from '@nestjs/jwt';
import type { User } from './types/authenticated.js';


@Injectable()
export class AuthService {
  constructor(private readonly usersService: UsersService,
    private jwtService: JwtService,
  ) { }
  
  async register(mobileNumber: string, password: string) {
    const passwordHash = await argon2.hash(password);
    return this.usersService.create(
      mobileNumber, passwordHash
    );
  }
  
  async validateUser( mobileNumber: string, password: string ) {
    const userExists = await this.usersService.findByMobileNumber(mobileNumber);
    if (!userExists) { return null; }
    const passwordHashMatches = await argon2.verify(userExists.passwordHash, password);
    if (!passwordHashMatches) { return null; }

    const { passwordHash,...safeUser } = userExists;
    return safeUser;
  }
 

  async login(user: User) {
    const payload = { username: user.mobileNumber, sub: user.userId };
    return {
      access_token: this.jwtService.sign(payload)
    }
  }
}
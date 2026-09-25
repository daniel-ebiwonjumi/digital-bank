import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service.js';
import * as argon2 from 'argon2';



@Injectable()
export class AuthService {
  constructor(private readonly usersService: UsersService) { }
  
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
}
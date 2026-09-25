import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service.js';
import { users } from '../db/schema/user.schema.js';



@Injectable()
class AuthService {
  constructor( private readonly usersService: UsersService ) { }
  
  async validateUser(mobileNumber: string, password: string) {
    const userExists = await this.usersService.findByMobileNumber(mobileNumber);
    if (!userExists) { return null; }
    const passwordHashMatches = await argon2.verify(users.passwordHash, password);
    if (!passwordHashMatches) { return null; }

    const { passwordHash,...safeUser } = userExists;
    return safeUser;
  }
}
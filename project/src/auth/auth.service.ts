import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { User } from '../users/users.service';


@Injectable()
export class AuthService {
    constructor(private readonly usersService: UsersService) { }
        
        async login(mobileNumber: string, pass: string) : Promise<Omit<User, 'password'>> {
            const user = await this.usersService.findMobileNumber(mobileNumber);
            if(user?.password !== pass) {
            throw new UnauthorizedException();
            }
            
            const { password, ...result } = user;
//TODO: Generate a JWT and return it here instead of the user object

            return result;


        }
    }


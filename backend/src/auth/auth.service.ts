import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';


@Injectable()
export class AuthService {
    constructor(private readonly usersService: UsersService,
        private jwtService : JwtService 
    ) { }
async login(mobileNumber: string, pass: string) : Promise<{access_token: string}> {
     const user = await this.usersService.findMobileNumber(mobileNumber);
    if(user?.password !== pass) {
            throw new UnauthorizedException();
            }
            
    const payload = { sub: user.id, mobileNumber: mobileNumber }
    return { access_token: await this.jwtService.signAsync(payload)}



        }
    }


import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from "passport-local";
import { AuthService } from "./auth.service.js";

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
    constructor(private readonly authService: AuthService) {
        super({
            usernameField: 'mobileNumber'
        });
    }
    async validate(mobileNumber: string, password: string) {
        const user = await this.authService.validateUser(mobileNumber, password);
        if (!user) {
            throw new UnauthorizedException();
        }
        return user;
        
    }
}

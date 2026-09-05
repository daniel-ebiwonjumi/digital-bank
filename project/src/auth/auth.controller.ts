import { Body, Controller, HttpCode, Post, } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
    constructor(private readonly authservice: AuthService) { }
    
    @HttpCode(HttpStatus.OK)
    @Post('login')
    login(@Body() LoginDto: Record<String, any>) {
        return this.authservice.login(LoginDto.mobileNumber, LoginDto.pass)
}
}

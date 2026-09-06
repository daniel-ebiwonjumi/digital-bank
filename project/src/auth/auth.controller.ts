import { Body, Controller, HttpCode, HttpStatus, Post, } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
    constructor(private readonly authservice: AuthService) { }
    
    @HttpCode(HttpStatus.OK)
    @Post('login')
    login(@Body() LoginDto: Record<string, string>) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return
    return this.authservice.login(LoginDto.mobileNumber, LoginDto.pass);
}
}

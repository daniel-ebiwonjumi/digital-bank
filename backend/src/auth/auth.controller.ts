import { Body, Controller, Get, HttpCode, HttpStatus, Post, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from './auth.guard';


export interface AuthenticatedRequest extends Request {
    user: {
        userId: string;
    };
}
@Controller('auth')
export class AuthController {
    constructor(private readonly authservice: AuthService) { }
    
    @HttpCode(HttpStatus.OK)
    @Post('login')
    login(@Body() loginDto: Record<string, string>) {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return
    return this.authservice.login(loginDto.mobileNumber, loginDto.pass);
    }
    @UseGuards(AuthGuard)
    @Get('profile')
    getProfile(@Request() req : AuthenticatedRequest) {
    
    return req.user;
    }

}

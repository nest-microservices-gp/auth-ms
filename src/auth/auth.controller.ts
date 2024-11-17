import { Controller, Get, Logger } from '@nestjs/common';
import { AuthService } from './auth.service';
import { MessagePattern, Payload } from '@nestjs/microservices';
import { AuthTCP } from 'src/common';
import { LoginUserDto, RegisterUserDto } from './dto';

@Controller()
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  private readonly logger = new Logger('Auth Controller');

  @MessagePattern(AuthTCP.REGISTER_USER)
  registerUser(@Payload() registerUserDto: RegisterUserDto) {
    return this.authService.registerUser(registerUserDto);
  }

  @MessagePattern(AuthTCP.LOGIN_USER)
  loginUser(@Payload() loginUserDto: LoginUserDto) {
    return this.authService.loginUser(loginUserDto);
  }

  @MessagePattern(AuthTCP.VERIFY_USER)
  verifyToken(@Payload() token: string) {
    return this.authService.verifyToken(token);
  }
}

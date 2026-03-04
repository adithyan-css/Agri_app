import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto, VerifyOtpDto } from './dto/login.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
    ) { }

    async loginDirect(loginDto: LoginDto) {
        let user = await this.usersService.findByPhoneNumber(loginDto.phoneNumber);

        if (!user) {
            // Auto-register via phone
            user = await this.usersService.create({ phoneNumber: loginDto.phoneNumber });
        }

        const loginResponse = this.login(user);
        return {
            token: loginResponse.access_token,
            user: loginResponse.user
        };
    }

    login(user: User) {
        const payload = { phoneNumber: user.phoneNumber, sub: user.id, role: user.role };
        return {
            access_token: this.jwtService.sign(payload),
            user,
        };
    }
}

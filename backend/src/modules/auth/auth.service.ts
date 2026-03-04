import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto, VerifyOtpDto } from './dto/login.dto';
import { User } from '../users/entities/user.entity';
import { RedisService } from 'nestjs-redis';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
        private readonly redisService: RedisService,
    ) { }

    async requestOtp(loginDto: LoginDto) {
        // In a real application, send OTP via SMS (e.g., Twilio / MSG91)
        const otp = '123456'; // Mock OTP for development

        // Store in Redis with 5 minutes expiry
        const redisClient = this.redisService.getClient();
        await redisClient.set(`otp:${loginDto.phoneNumber}`, otp, 'EX', 300);

        return { message: 'OTP sent successfully', mockOtp: otp };
    }

    async verifyOtp(verifyOtpDto: VerifyOtpDto) {
        const redisClient = this.redisService.getClient();
        const storedOtp = await redisClient.get(`otp:${verifyOtpDto.phoneNumber}`);

        // UNIVERSAL BYPASS FOR DEVELOPMENT
        const isBypass = verifyOtpDto.otp === '123456';

        if (!isBypass && storedOtp !== verifyOtpDto.otp) {
            throw new UnauthorizedException('Invalid or expired OTP');
        }

        // Clear OTP after successful use
        if (!isBypass) {
            await redisClient.del(`otp:${verifyOtpDto.phoneNumber}`);
        }

        let user = await this.usersService.findByPhoneNumber(verifyOtpDto.phoneNumber);

        if (!user) {
            // Auto-register via phone
            user = await this.usersService.create({ phoneNumber: verifyOtpDto.phoneNumber });
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

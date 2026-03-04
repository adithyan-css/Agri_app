import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto, VerifyOtpDto } from './dto/login.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
    private readonly logger = new Logger(AuthService.name);
    // In-memory OTP store (use Redis in production)
    private otpStore: Map<string, { otp: string; expiresAt: Date }> = new Map();

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

    /**
     * Send OTP to the given phone number.
     * In production, integrate with an SMS gateway (Twilio, MSG91, etc.).
     * For development, the OTP is logged and stored in memory with a 5-minute TTL.
     */
    async sendOtp(phoneNumber: string): Promise<{ message: string }> {
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

        this.otpStore.set(phoneNumber, { otp, expiresAt });
        this.logger.log(`[OTP] ${phoneNumber} => ${otp} (expires: ${expiresAt.toISOString()})`);

        // TODO: Send via SMS gateway in production
        // await this.smsService.send(phoneNumber, `Your AgriPrice OTP is: ${otp}`);

        return { message: 'OTP sent successfully' };
    }

    /**
     * Verify OTP and return JWT token + user.
     * Auto-registers the user if they don't exist.
     */
    async verifyOtp(verifyOtpDto: VerifyOtpDto): Promise<{ token: string; user: User }> {
        const { phoneNumber, otp } = verifyOtpDto;
        const stored = this.otpStore.get(phoneNumber);

        if (!stored) {
            throw new UnauthorizedException('No OTP was sent to this number. Please request a new one.');
        }

        if (new Date() > stored.expiresAt) {
            this.otpStore.delete(phoneNumber);
            throw new UnauthorizedException('OTP has expired. Please request a new one.');
        }

        if (stored.otp !== otp) {
            throw new UnauthorizedException('Invalid OTP. Please try again.');
        }

        // OTP verified — clean up
        this.otpStore.delete(phoneNumber);

        // Auto-register or find user
        let user = await this.usersService.findByPhoneNumber(phoneNumber);
        if (!user) {
            user = await this.usersService.create({ phoneNumber });
        }

        // Mark as verified
        user.isVerified = true;
        await this.usersService.update(user.id, { isVerified: true });

        const loginResponse = this.login(user);
        return {
            token: loginResponse.access_token,
            user: loginResponse.user,
        };
    }
}

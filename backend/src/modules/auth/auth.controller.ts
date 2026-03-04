import { Controller, Post, Body, HttpCode, HttpStatus, Get, UseGuards, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { FirebaseAuthGuard } from './guards/firebase-auth.guard';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
    constructor(private readonly authService: AuthService) { }

    @Post('sync')
    @HttpCode(HttpStatus.OK)
    @UseGuards(FirebaseAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Sync Firebase user to local database' })
    @ApiResponse({ status: 200, description: 'User synced and returned' })
    syncUser(@Request() req) {
        return this.authService.syncFirebaseUser(req.user);
    }

    @Get('profile')
    @UseGuards(FirebaseAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get current user profile' })
    getProfile(@Request() req) {
        return this.authService.getOrCreateUser(req.user);
    }
}

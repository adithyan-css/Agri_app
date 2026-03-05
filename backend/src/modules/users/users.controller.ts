import { Controller, Get, Param, Patch, Body, Req, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiBearerAuth, ApiTags, ApiOperation } from '@nestjs/swagger';
import { Request } from 'express';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Get('me/preferred-market')
    @ApiOperation({ summary: 'Get current user preferred market ID' })
    async getPreferredMarket(@Req() req: Request) {
        const firebaseUid = (req as any).user?.uid;
        const marketId = await this.usersService.getPreferredMarket(firebaseUid);
        return { preferredMarketId: marketId };
    }

    @Patch('me/preferred-market')
    @ApiOperation({ summary: 'Set preferred market for current user' })
    async setPreferredMarket(@Req() req: Request, @Body() body: { marketId: string }) {
        const firebaseUid = (req as any).user?.uid;
        const user = await this.usersService.updatePreferredMarket(firebaseUid, body.marketId);
        return { preferredMarketId: user.preferredMarketId };
    }

    @Get(':id')
    async findOne(@Param('id') id: string) {
        return this.usersService.findOne(id);
    }
}

import { Controller, Post, Get, Patch, Delete, Body, Param, Req, UseGuards } from '@nestjs/common';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UsersService } from '../users/users.service';

@ApiTags('Alerts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('alerts')
export class AlertsController {
    constructor(
        private readonly alertsService: AlertsService,
        private readonly usersService: UsersService,
    ) { }

    /** Resolve the internal DB user UUID from the Firebase UID on the request. */
    private async getUserId(req: any): Promise<string> {
        const firebaseUid = req.user?.uid;
        if (!firebaseUid) throw new Error('No Firebase UID on request');
        const user = await this.usersService.findByFirebaseUid(firebaseUid);
        if (!user) {
            // Auto-create user record if it doesn't exist yet
            const created = await this.usersService.create({
                firebaseUid,
                phoneNumber: req.user.phoneNumber || `firebase_${firebaseUid}`,
                name: req.user.name || req.user.email || 'User',
            });
            return created.id;
        }
        return user.id;
    }

    @Post()
    @ApiOperation({ summary: 'Create a new price alert' })
    async create(@Body() dto: CreateAlertDto, @Req() req: any) {
        const userId = await this.getUserId(req);
        return this.alertsService.createAlert(userId, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get active alerts for the user' })
    async findAll(@Req() req: any) {
        const userId = await this.getUserId(req);
        return this.alertsService.findByUser(userId);
    }

    @Patch(':id')
    @ApiOperation({ summary: 'Toggle alert active status' })
    async toggle(@Param('id') id: string, @Body() body: { isActive: boolean }, @Req() req: any) {
        const userId = await this.getUserId(req);
        return this.alertsService.toggleAlert(id, userId, body.isActive);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Deactivate an alert' })
    async remove(@Param('id') id: string, @Req() req: any) {
        const userId = await this.getUserId(req);
        return this.alertsService.deleteAlert(id, userId);
    }
}

import { Controller, Post, Get, Delete, Body, Param, Req } from '@nestjs/common';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Alerts')
@Controller('alerts')
export class AlertsController {
    constructor(private readonly alertsService: AlertsService) { }

    @Post()
    @ApiOperation({ summary: 'Create a new price alert' })
    create(@Body() dto: CreateAlertDto) {
        // For current public testing phase, we'll hardcode a test user ID
        // In prod, this would come from @Req() user.id via JWT
        const testUserId = 'u0000000-0000-0000-0000-000000000001';
        return this.alertsService.createAlert(testUserId, dto);
    }

    @Get()
    @ApiOperation({ summary: 'Get active alerts for the user' })
    findAll() {
        const testUserId = 'u0000000-0000-0000-0000-000000000001';
        return this.alertsService.findByUser(testUserId);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Deactivate an alert' })
    remove(@Param('id') id: string) {
        const testUserId = 'u0000000-0000-0000-0000-000000000001';
        return this.alertsService.deleteAlert(id, testUserId);
    }
}

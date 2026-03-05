import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

export interface RouteResult {
    distanceKm: number;
    durationMinutes: number;
}

@Injectable()
export class RoutingService {
    private readonly logger = new Logger(RoutingService.name);
    private readonly apiKey: string;
    private readonly baseUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';

    constructor(private readonly configService: ConfigService) {
        this.apiKey = this.configService.get<string>('OPENROUTE_API_KEY', '');
        if (!this.apiKey) {
            this.logger.warn('OPENROUTE_API_KEY is not set — routing will fail');
        }
    }

    /**
     * Get real road distance and travel time between two GPS points.
     * Uses OpenRouteService driving-car profile.
     *
     * @param fromLng Origin longitude
     * @param fromLat Origin latitude
     * @param toLng   Destination longitude
     * @param toLat   Destination latitude
     */
    async getRoute(
        fromLng: number,
        fromLat: number,
        toLng: number,
        toLat: number,
    ): Promise<RouteResult> {
        const body = {
            coordinates: [
                [fromLng, fromLat],
                [toLng, toLat],
            ],
        };

        const response = await axios.post(this.baseUrl, body, {
            headers: {
                Authorization: this.apiKey,
                'Content-Type': 'application/json',
            },
            timeout: 10_000,
        });

        const segment = response.data?.routes?.[0]?.summary;
        if (!segment) {
            throw new Error('No route returned from OpenRouteService');
        }

        return {
            distanceKm: Math.round((segment.distance / 1000) * 10) / 10,
            durationMinutes: Math.round(segment.duration / 60),
        };
    }

    /**
     * Batch-fetch road distances from a single origin to multiple destinations.
     * Calls ORS sequentially to respect rate limits (free tier: 40 req/min).
     */
    async getRoutesToMany(
        fromLng: number,
        fromLat: number,
        destinations: { lng: number; lat: number; id: string }[],
    ): Promise<Map<string, RouteResult>> {
        const results = new Map<string, RouteResult>();

        for (const dest of destinations) {
            try {
                const route = await this.getRoute(fromLng, fromLat, dest.lng, dest.lat);
                results.set(dest.id, route);
            } catch (err) {
                this.logger.warn(`Route to ${dest.id} failed: ${err.message}`);
                // Fallback: leave entry absent — caller must handle missing routes
            }
        }

        return results;
    }
}

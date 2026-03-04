import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Market } from './entities/market.entity';
import { NearbyMarketsDto } from './dto/nearby-markets.dto';

@Injectable()
export class MarketsService {
    constructor(
        @InjectRepository(Market)
        private readonly marketRepository: Repository<Market>,
    ) { }

    async findAll(): Promise<Market[]> {
        return this.marketRepository.find({ where: { isActive: true } });
    }

    /**
     * Finds nearby markets using PostGIS ST_Distance computation
     * Formula: ST_Distance returns meters for geography types
     */
    async findNearbyMarkets(query: NearbyMarketsDto): Promise<Market[]> {
        const radiusMeters = (query.radiusKm || 50) * 1000;

        // We use QueryBuilder to inject raw PostGIS ST_Distance logic
        // This allows PostgreSQL to sort locations blazingly fast using GIST index
        const markets = await this.marketRepository
            .createQueryBuilder('market')
            .addSelect(
                `ST_Distance(market.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)) / 1000`,
                'distanceKm'
            )
            .where(
                `ST_DWithin(market.location, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326), :radiusMeters)`
            )
            .andWhere('market.isActive = true')
            .setParameters({
                lng: query.lng,
                lat: query.lat,
                radiusMeters
            })
            .orderBy('distanceKm', 'ASC')
            .getRawAndEntities();

        // Map raw DB distance back into entities for clean return
        return markets.entities.map((entity, index) => {
            // TypeORM's getRawAndEntities maps the raw ST_Distance result at the matching index
            entity.distanceKm = Math.round(markets.raw[index].distanceKm * 10) / 10;
            return entity;
        });
    }
}

import { Injectable, CanActivate, ExecutionContext, UnauthorizedException, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

/**
 * Guard that verifies Firebase ID tokens from the Authorization header.
 * 
 * Usage: @UseGuards(FirebaseAuthGuard) on controllers or routes.
 * 
 * After verification, `request.user` is populated with:
 *   - uid: Firebase UID
 *   - email: user email (if available)
 *   - name: display name (if available)
 *   - firebase: the full decoded token
 */
@Injectable()
export class FirebaseAuthGuard implements CanActivate {
    private readonly logger = new Logger(FirebaseAuthGuard.name);

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const authHeader = request.headers['authorization'];

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            throw new UnauthorizedException('Missing or invalid Authorization header');
        }

        const token = authHeader.replace('Bearer ', '');

        try {
            const decodedToken = await admin.auth().verifyIdToken(token);

            // Attach decoded user info to request for downstream use
            request.user = {
                uid: decodedToken.uid,
                email: decodedToken.email || null,
                name: decodedToken.name || null,
                phoneNumber: decodedToken.phone_number || null,
                role: 'farmer', // Default role; can be enriched from DB
                firebase: decodedToken,
            };

            return true;
        } catch (error) {
            this.logger.warn(`Firebase token verification failed: ${error.message}`);
            throw new UnauthorizedException('Invalid or expired Firebase token');
        }
    }
}

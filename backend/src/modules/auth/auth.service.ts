import { Injectable, Logger } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
    private readonly logger = new Logger(AuthService.name);

    constructor(
        private usersService: UsersService,
    ) { }

    /**
     * Sync a Firebase-authenticated user to the local database.
     * Creates the user if they don't exist, or returns the existing one.
     */
    async syncFirebaseUser(firebaseUser: { uid: string; email?: string; name?: string; phoneNumber?: string }): Promise<User> {
        return this.getOrCreateUser(firebaseUser);
    }

    /**
     * Get an existing user by Firebase UID, or create a new one.
     */
    async getOrCreateUser(firebaseUser: { uid: string; email?: string; name?: string; phoneNumber?: string }): Promise<User> {
        let user = await this.usersService.findByFirebaseUid(firebaseUser.uid);

        if (!user) {
            this.logger.log(`Creating new user for Firebase UID: ${firebaseUser.uid}`);
            user = await this.usersService.create({
                firebaseUid: firebaseUser.uid,
                phoneNumber: firebaseUser.phoneNumber || firebaseUser.email || firebaseUser.uid,
                name: firebaseUser.name,
            });
        }

        return user;
    }
}

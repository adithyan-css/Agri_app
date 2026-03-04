import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';

/**
 * Decorator to set required roles on a route handler.
 * Usage: @Roles('admin', 'farmer')
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

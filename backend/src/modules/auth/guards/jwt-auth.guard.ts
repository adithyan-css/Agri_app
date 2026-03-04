// Firebase Auth Guard — replaces the old JWT/Passport guard.
// All controllers using @UseGuards(JwtAuthGuard) now verify Firebase ID tokens.
export { FirebaseAuthGuard as JwtAuthGuard } from './firebase-auth.guard';

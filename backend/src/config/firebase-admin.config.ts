import * as admin from 'firebase-admin';

/**
 * Initialize the Firebase Admin SDK.
 * 
 * In production, set the GOOGLE_APPLICATION_CREDENTIALS env variable
 * pointing to your service account JSON file, or deploy on GCP where
 * default credentials are available.
 * 
 * For local development, download the service account key from:
 * Firebase Console → Project Settings → Service Accounts → Generate new private key
 * Then set: GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json
 */
export function initializeFirebaseAdmin(): admin.app.App {
    if (admin.apps.length > 0) {
        return admin.apps[0];
    }

    // If a service account path is provided, use it explicitly
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (serviceAccountPath) {
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        const serviceAccount = require(serviceAccountPath);
        return admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
        });
    }

    // For local development: initialize with just the project ID.
    // verifyIdToken() uses Google's public keys and only needs the project ID.
    // For production with other Admin features, use GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_SERVICE_ACCOUNT_PATH.
    const projectId = process.env.FIREBASE_PROJECT_ID || 'agriai-b0313';
    
    try {
        // Try Application Default Credentials first (works on GCP or with GOOGLE_APPLICATION_CREDENTIALS)
        return admin.initializeApp({
            credential: admin.credential.applicationDefault(),
            projectId,
        });
    } catch {
        // Fallback: initialize without credentials (sufficient for verifyIdToken)
        return admin.initializeApp({ projectId });
    }
}

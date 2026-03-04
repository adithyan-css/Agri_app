import { Injectable, Logger } from '@nestjs/common';

/**
 * Notifications Service
 * ─────────────────────
 * Handles push notifications via Firebase Cloud Messaging (FCM).
 *
 * In production, install `firebase-admin`:
 *   npm install firebase-admin
 *
 * Then initialize with your service account key:
 *   import * as admin from 'firebase-admin';
 *   admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
 *
 * For now, this uses a mock implementation that logs notifications.
 * Replace the mock with real FCM calls when deploying.
 */
@Injectable()
export class NotificationsService {
    private readonly logger = new Logger(NotificationsService.name);

    /**
     * Send a push notification to a user.
     * In a real setup, this would look up the user's FCM token
     * from the database and send via Firebase Admin SDK.
     *
     * @param userId - The user's UUID
     * @param title  - Notification title (e.g., "Price Alert!")
     * @param body   - Notification body text
     * @param data   - Optional extra data payload for the mobile app
     */
    async sendNotification(
        userId: string,
        title: string,
        body: string,
        data?: Record<string, string>,
    ) {
        this.logger.log(`[PUSH] User: ${userId} | Title: ${title} | Body: ${body}`);

        // ─── PRODUCTION FCM CODE (uncomment when firebase-admin is installed) ───
        // try {
        //     // Step 1: Look up the user's FCM device token from the database
        //     // const user = await this.usersService.findById(userId);
        //     // if (!user?.deviceFcmToken) {
        //     //     this.logger.warn(`No FCM token for user ${userId}`);
        //     //     return { success: false, reason: 'no_fcm_token' };
        //     // }
        //
        //     // Step 2: Send notification via Firebase Admin SDK
        //     // const message: admin.messaging.Message = {
        //     //     notification: { title, body },
        //     //     data: data || {},
        //     //     token: user.deviceFcmToken,
        //     // };
        //     // const response = await admin.messaging().send(message);
        //     // this.logger.log(`FCM sent successfully: ${response}`);
        //     // return { success: true, messageId: response, timestamp: new Date() };
        // } catch (error) {
        //     this.logger.error(`FCM send failed for user ${userId}: ${error.message}`);
        //     return { success: false, error: error.message };
        // }

        // Mock response for development
        return { success: true, timestamp: new Date() };
    }

    /**
     * Send a price alert notification with structured data.
     * The mobile app can use the data payload to deep-link to the alert screen.
     */
    async sendPriceAlert(
        userId: string,
        cropName: string,
        currentPrice: number,
        targetPrice: number,
        condition: string,
    ) {
        const title = '🔔 Price Alert Triggered!';
        const body = `${cropName} has reached ₹${currentPrice.toFixed(2)}/kg `
            + `(your target: ₹${targetPrice.toFixed(2)}/kg ${condition}).`;

        return this.sendNotification(userId, title, body, {
            type: 'price_alert',
            cropName,
            currentPrice: currentPrice.toString(),
            targetPrice: targetPrice.toString(),
        });
    }
}

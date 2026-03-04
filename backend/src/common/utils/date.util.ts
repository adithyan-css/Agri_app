/**
 * Format a Date to 'YYYY-MM-DD' string.
 */
export function formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
}

/**
 * Get the start of today (midnight, local time).
 */
export function startOfToday(): Date {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d;
}

/**
 * Get a Date n days ago from now.
 */
export function daysAgo(n: number): Date {
    const d = new Date();
    d.setDate(d.getDate() - n);
    return d;
}

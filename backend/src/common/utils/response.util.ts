/**
 * Standard success response wrapper.
 */
export function successResponse<T>(data: T, message = 'Success') {
    return {
        success: true,
        message,
        data,
    };
}

/**
 * Standard paginated response wrapper.
 */
export function paginatedResponse<T>(data: T[], total: number, page: number, limit: number) {
    return {
        success: true,
        data,
        meta: {
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
        },
    };
}

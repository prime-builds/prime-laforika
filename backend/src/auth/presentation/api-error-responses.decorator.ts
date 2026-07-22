import { applyDecorators } from '@nestjs/common';
import { ApiResponse } from '@nestjs/swagger';
import { ErrorResponseDto } from './auth.dto';

const STATUS_DESCRIPTIONS: Record<number, string> = {
  400: 'Validation or challenge error',
  401: 'Unauthorized',
  404: 'Resource not found',
  409: 'Credential conflict',
  429: 'Rate limited',
  503: 'Delivery unavailable',
};

/** Documents applicable non-2xx auth/account responses using ErrorResponseDto. */
export function ApiAuthErrors(...statuses: number[]) {
  return applyDecorators(
    ...statuses.map((status) =>
      ApiResponse({
        status,
        type: ErrorResponseDto,
        description: STATUS_DESCRIPTIONS[status] ?? `HTTP ${status}`,
      }),
    ),
  );
}

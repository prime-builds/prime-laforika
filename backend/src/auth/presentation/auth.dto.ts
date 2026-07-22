import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';

export class PhoneDto {
  @ApiProperty({
    type: String,
    required: true,
    minLength: 1,
    example: '+989121234567',
  })
  @IsString()
  @MinLength(1)
  phone!: string;
}

export class CodeDto {
  @ApiProperty({ type: String, required: true, minLength: 1 })
  @IsString()
  @MinLength(1)
  code!: string;
}

export class EmailSignUpDto {
  @ApiProperty({
    type: String,
    required: true,
    format: 'email',
    example: 'user@example.com',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    type: String,
    required: true,
    minLength: 15,
    format: 'password',
  })
  @IsString()
  @MinLength(15)
  password!: string;
}

export class EmailVerifyDto {
  @ApiProperty({ type: String, required: true, format: 'uuid' })
  @IsString()
  @MinLength(1)
  challengeId!: string;

  @ApiProperty({ type: String, required: true, minLength: 1 })
  @IsString()
  @MinLength(1)
  code!: string;
}

export class EmailSignInDto {
  @ApiProperty({
    type: String,
    required: true,
    format: 'email',
    example: 'user@example.com',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    type: String,
    required: true,
    minLength: 1,
    format: 'password',
  })
  @IsString()
  @MinLength(1)
  password!: string;
}

export class ResetChallengeDto {
  @ApiProperty({
    type: String,
    required: true,
    format: 'email',
    example: 'user@example.com',
  })
  @IsEmail()
  email!: string;
}

export class ResetPasswordDto {
  @ApiProperty({ type: String, required: true, format: 'uuid' })
  @IsString()
  @MinLength(1)
  challengeId!: string;

  @ApiProperty({ type: String, required: true, minLength: 1 })
  @IsString()
  @MinLength(1)
  code!: string;

  @ApiProperty({
    type: String,
    required: true,
    minLength: 15,
    format: 'password',
  })
  @IsString()
  @MinLength(15)
  newPassword!: string;
}

export class RefreshDto {
  @ApiProperty({ type: String, required: true, minLength: 1 })
  @IsString()
  @MinLength(1)
  refreshToken!: string;
}

export class AttachEmailDto {
  @ApiProperty({
    type: String,
    required: true,
    format: 'email',
    example: 'user@example.com',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    type: String,
    required: true,
    minLength: 15,
    format: 'password',
  })
  @IsString()
  @MinLength(15)
  password!: string;
}

export class ChangePasswordDto {
  @ApiProperty({
    type: String,
    required: true,
    minLength: 1,
    format: 'password',
  })
  @IsString()
  @MinLength(1)
  currentPassword!: string;

  @ApiProperty({
    type: String,
    required: true,
    minLength: 15,
    format: 'password',
  })
  @IsString()
  @MinLength(15)
  newPassword!: string;
}

export class ChallengeResponseDto {
  @ApiProperty({ type: String, format: 'uuid' })
  challengeId!: string;

  @ApiProperty({ type: String })
  maskedDestination!: string;

  @ApiProperty({ type: String, format: 'date-time' })
  resendAvailableAt!: string;

  @ApiProperty({ type: String, format: 'date-time' })
  expiresAt!: string;
}

export class AccountViewDto {
  @ApiProperty({ type: String, format: 'uuid' })
  accountId!: string;

  @ApiProperty({ type: Boolean })
  hasPhone!: boolean;

  @ApiProperty({ type: Boolean })
  hasEmail!: boolean;

  @ApiPropertyOptional({ type: String, nullable: true })
  maskedPhone!: string | null;

  @ApiPropertyOptional({ type: String, nullable: true })
  maskedEmail!: string | null;
}

export class TokenResponseDto extends AccountViewDto {
  @ApiProperty({ type: String })
  accessToken!: string;

  @ApiProperty({ type: String })
  refreshToken!: string;

  @ApiPropertyOptional({ type: String, format: 'uuid' })
  sessionId?: string;
}

export class OkResponseDto {
  @ApiProperty({ type: Boolean })
  ok!: boolean;
}

export class HealthResponseDto {
  @ApiProperty({ type: String, example: 'ok' })
  status!: string;
}

export class SessionListItemDto {
  @ApiProperty({ type: String, format: 'uuid' })
  sessionId!: string;

  @ApiProperty({ type: String, format: 'date-time' })
  createdAt!: string;

  @ApiProperty({ type: String, format: 'date-time' })
  lastSeenAt!: string;

  @ApiProperty({ type: Boolean })
  isCurrent!: boolean;

  @ApiPropertyOptional({ type: String, nullable: true })
  deviceLabel!: string | null;

  @ApiProperty({ type: Boolean })
  revoked!: boolean;
}

export class ErrorResponseDto {
  @ApiProperty({ type: String, example: 'AUTH_INVALID_CREDENTIALS' })
  code!: string;

  @ApiProperty({ type: String, example: 'Request failed' })
  message!: string;

  @ApiProperty({ type: String, format: 'uuid' })
  correlationId!: string;

  @ApiPropertyOptional()
  details?: unknown;
}

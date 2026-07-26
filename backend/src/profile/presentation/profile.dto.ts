import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEmail,
  IsOptional,
  IsString,
  MaxLength,
  ValidateIf,
} from 'class-validator';

/** Trim strings before validation; blank becomes null (clear). */
function trimBlankToNull({ value }: { value: unknown }): unknown {
  if (value === null || value === undefined) {
    return value;
  }
  if (typeof value !== 'string') {
    return value;
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

export class ProfileViewDto {
  @ApiProperty({ type: String, format: 'uuid' })
  accountId!: string;

  @ApiProperty({ type: String, example: '+989121234567' })
  phone!: string;

  @ApiProperty({ type: Boolean })
  phoneVerified!: boolean;

  @ApiProperty({
    type: String,
    nullable: true,
    required: true,
    maxLength: 100,
  })
  firstName!: string | null;

  @ApiProperty({
    type: String,
    nullable: true,
    required: true,
    maxLength: 100,
  })
  lastName!: string | null;

  @ApiProperty({
    type: String,
    nullable: true,
    required: true,
    maxLength: 254,
    format: 'email',
  })
  email!: string | null;

  @ApiProperty({ type: Boolean })
  emailVerified!: boolean;
}

export class PatchProfileDto {
  @ApiPropertyOptional({
    type: String,
    nullable: true,
    maxLength: 100,
    description: 'Omit to leave unchanged; null or blank clears.',
  })
  @IsOptional()
  @Transform(trimBlankToNull)
  @ValidateIf((_, value) => value !== null)
  @IsString()
  @MaxLength(100)
  firstName?: string | null;

  @ApiPropertyOptional({
    type: String,
    nullable: true,
    maxLength: 100,
    description: 'Omit to leave unchanged; null or blank clears.',
  })
  @IsOptional()
  @Transform(trimBlankToNull)
  @ValidateIf((_, value) => value !== null)
  @IsString()
  @MaxLength(100)
  lastName?: string | null;

  @ApiPropertyOptional({
    type: String,
    nullable: true,
    maxLength: 254,
    format: 'email',
    description:
      'Optional contact email. Omit unchanged; null or blank clears.',
  })
  @IsOptional()
  @Transform(trimBlankToNull)
  @ValidateIf((_, value) => value !== null)
  @IsEmail()
  @MaxLength(254)
  email?: string | null;
}

export { ErrorResponseDto } from '../../auth/presentation/auth.dto';

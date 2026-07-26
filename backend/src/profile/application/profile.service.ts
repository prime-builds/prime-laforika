import { Injectable } from '@nestjs/common';
import { Prisma, type User } from '@prisma/client';
import { AppError } from '../../common/errors/app-error';
import { normalizeEmail } from '../../common/security/crypto.util';
import { PrismaService } from '../../database/prisma.service';
import type {
  PatchProfileDto,
  ProfileViewDto,
} from '../presentation/profile.dto';

const NAME_MAX_CHARS = 100;
const EMAIL_MAX_CHARS = 254;

@Injectable()
export class ProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async getProfile(accountId: string): Promise<ProfileViewDto> {
    const user = await this.requireActiveUser(accountId);
    return this.toView(user);
  }

  async patchProfile(
    accountId: string,
    body: PatchProfileDto,
  ): Promise<ProfileViewDto> {
    await this.requireActiveUser(accountId);

    const data: Prisma.UserUpdateInput = {};

    if (Object.prototype.hasOwnProperty.call(body, 'firstName')) {
      data.firstName = this.normalizeName(body.firstName, 'firstName');
    }
    if (Object.prototype.hasOwnProperty.call(body, 'lastName')) {
      data.lastName = this.normalizeName(body.lastName, 'lastName');
    }
    if (Object.prototype.hasOwnProperty.call(body, 'email')) {
      const emailPatch = this.normalizeContactEmail(body.email);
      const current = await this.prisma.user.findUniqueOrThrow({
        where: { id: accountId },
      });
      if (emailPatch.normalized !== (current.emailNormalized ?? null)) {
        data.emailNormalized = emailPatch.normalized;
        data.emailDisplay = emailPatch.display;
        data.emailVerifiedAt = null;
      } else if (
        emailPatch.normalized !== null &&
        emailPatch.display !== current.emailDisplay
      ) {
        // Display-form cleanup without clearing verification.
        data.emailDisplay = emailPatch.display;
      } else if (emailPatch.normalized === null) {
        data.emailNormalized = null;
        data.emailDisplay = null;
        data.emailVerifiedAt = null;
      }
    }

    if (Object.keys(data).length === 0) {
      const unchanged = await this.prisma.user.findUniqueOrThrow({
        where: { id: accountId },
      });
      return this.toView(unchanged);
    }

    try {
      const updated = await this.prisma.user.update({
        where: { id: accountId },
        data,
      });
      return this.toView(updated);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new AppError('PROFILE_EMAIL_IN_USE', 409, ['email']);
      }
      throw error;
    }
  }

  private async requireActiveUser(accountId: string): Promise<User> {
    const user = await this.prisma.user.findUnique({
      where: { id: accountId },
    });
    if (!user || user.disabledAt) {
      throw new AppError('AUTH_ACCOUNT_UNAVAILABLE', 401);
    }
    return user;
  }

  private toView(user: User): ProfileViewDto {
    return {
      accountId: user.id,
      phone: user.phoneE164,
      phoneVerified: true,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.emailDisplay,
      emailVerified: user.emailVerifiedAt != null,
    };
  }

  private normalizeName(
    value: string | null | undefined,
    field: 'firstName' | 'lastName',
  ): string | null {
    if (value === null || value === undefined) {
      return null;
    }
    const trimmed = value.trim();
    if (!trimmed) {
      return null;
    }
    if ([...trimmed].length > NAME_MAX_CHARS) {
      throw new AppError('VALIDATION_ERROR', 400, [field]);
    }
    return trimmed;
  }

  private normalizeContactEmail(value: string | null | undefined): {
    display: string | null;
    normalized: string | null;
  } {
    if (value === null || value === undefined) {
      return { display: null, normalized: null };
    }
    const trimmed = value.trim();
    if (!trimmed) {
      return { display: null, normalized: null };
    }
    if (trimmed.length > EMAIL_MAX_CHARS) {
      throw new AppError('VALIDATION_ERROR', 400, ['email']);
    }
    const normalized = normalizeEmail(trimmed);
    if (!isSyntacticallyValidEmail(normalized)) {
      throw new AppError('VALIDATION_ERROR', 400, ['email']);
    }
    return { display: trimmed, normalized };
  }
}

function isSyntacticallyValidEmail(email: string): boolean {
  // Conservative RFC-inspired check without a new dependency.
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) && !email.includes('..');
}

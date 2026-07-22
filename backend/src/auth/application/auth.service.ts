import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ChallengePurpose } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { AppError } from '../../common/errors/app-error';
import {
  assertPasswordPolicy,
  hashPassword,
  normalizeEmail,
  normalizePhone,
  toLatinDigits,
  verifyPassword,
} from '../../common/security/crypto.util';
import { ChallengeService, SessionService } from './session.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly challenges: ChallengeService,
    private readonly sessions: SessionService,
  ) {}

  async requestPhoneChallenge(phoneRaw: string, originFingerprint?: string) {
    const phone = normalizePhone(phoneRaw);
    return this.challenges.createChallenge({
      purpose: ChallengePurpose.PHONE_SIGN_IN,
      destinationType: 'PHONE',
      destinationNormalized: phone,
      originFingerprint,
    });
  }

  async verifyPhoneChallenge(challengeId: string, codeRaw: string) {
    const code = toLatinDigits(codeRaw).trim();
    const challenge = await this.challenges.consumeChallenge(challengeId, code);
    if (challenge.purpose !== ChallengePurpose.PHONE_SIGN_IN) {
      throw new AppError('AUTH_CHALLENGE_INVALID', 400);
    }
    let user = await this.prisma.user.findUnique({
      where: { phoneE164: challenge.destinationNormalized },
    });
    if (!user) {
      user = await this.prisma.user.create({
        data: { phoneE164: challenge.destinationNormalized },
      });
    }
    if (user.disabledAt) throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
    const tokens = await this.sessions.createSession(user.id);
    return { ...tokens, ...this.sessions.accountView(user) };
  }

  async emailSignUp(
    emailRaw: string,
    password: string,
    originFingerprint?: string,
  ) {
    const email = normalizeEmail(emailRaw);
    assertPasswordPolicy(password);

    const verifiedOwner = await this.prisma.user.findFirst({
      where: {
        emailNormalized: email,
        emailVerifiedAt: { not: null },
        passwordHash: { not: null },
      },
    });
    if (verifiedOwner) {
      throw new AppError('AUTH_CONFLICT', 409);
    }

    const passwordHash = await hashPassword(
      password,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );

    // Pending credentials live on the challenge only — not on User.
    return this.challenges.createChallenge({
      purpose: ChallengePurpose.EMAIL_VERIFY,
      destinationType: 'EMAIL',
      destinationNormalized: email,
      pendingPasswordHash: passwordHash,
      pendingEmailDisplay: emailRaw.trim(),
      originFingerprint,
    });
  }

  async emailVerify(challengeId: string, codeRaw: string) {
    const challenge = await this.challenges.consumeChallenge(
      challengeId,
      toLatinDigits(codeRaw).trim(),
    );
    if (
      challenge.purpose !== ChallengePurpose.EMAIL_VERIFY ||
      !challenge.pendingPasswordHash
    ) {
      throw new AppError('AUTH_CHALLENGE_INVALID', 400);
    }

    const email = challenge.destinationNormalized;
    const existing = await this.prisma.user.findUnique({
      where: { emailNormalized: email },
    });
    if (existing?.emailVerifiedAt) {
      throw new AppError('AUTH_CONFLICT', 409);
    }

    let user;
    try {
      user = await this.prisma.user.create({
        data: {
          emailNormalized: email,
          emailDisplay: challenge.pendingEmailDisplay ?? email,
          passwordHash: challenge.pendingPasswordHash,
          emailVerifiedAt: new Date(),
        },
      });
    } catch {
      throw new AppError('AUTH_CONFLICT', 409);
    }

    const tokens = await this.sessions.createSession(user.id);
    return { ...tokens, ...this.sessions.accountView(user) };
  }

  async emailSignIn(emailRaw: string, password: string) {
    const email = normalizeEmail(emailRaw);
    const user = await this.prisma.user.findUnique({
      where: { emailNormalized: email },
    });
    if (!user?.passwordHash || !user.emailVerifiedAt || user.disabledAt) {
      throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
    }
    const verified = await verifyPassword(
      user.passwordHash,
      password,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );
    if (!verified.ok) {
      throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
    }
    if (verified.needsRehash) {
      const passwordHash = await hashPassword(
        password,
        this.config.getOrThrow('PASSWORD_PEPPER'),
      );
      await this.prisma.user.update({
        where: { id: user.id },
        data: { passwordHash },
      });
    }
    const tokens = await this.sessions.createSession(user.id);
    return { ...tokens, ...this.sessions.accountView(user) };
  }

  async requestPasswordReset(emailRaw: string, originFingerprint?: string) {
    const email = normalizeEmail(emailRaw);
    const user = await this.prisma.user.findFirst({
      where: {
        emailNormalized: email,
        emailVerifiedAt: { not: null },
        passwordHash: { not: null },
      },
    });
    // Enumeration-resistant: always-looking response when absent.
    if (!user) {
      return {
        challengeId: '00000000-0000-0000-0000-000000000000',
        maskedDestination: '***',
        resendAvailableAt: new Date(Date.now() + 60_000).toISOString(),
        expiresAt: new Date(Date.now() + 300_000).toISOString(),
      };
    }
    return this.challenges.createChallenge({
      purpose: ChallengePurpose.PASSWORD_RESET,
      destinationType: 'EMAIL',
      destinationNormalized: email,
      userId: user.id,
      originFingerprint,
    });
  }

  async resetPassword(
    challengeId: string,
    codeRaw: string,
    newPassword: string,
  ) {
    assertPasswordPolicy(newPassword);
    const challenge = await this.challenges.consumeChallenge(
      challengeId,
      toLatinDigits(codeRaw).trim(),
    );
    if (
      challenge.purpose !== ChallengePurpose.PASSWORD_RESET ||
      !challenge.userId
    ) {
      throw new AppError('AUTH_CHALLENGE_INVALID', 400);
    }
    const passwordHash = await hashPassword(
      newPassword,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );
    await this.prisma.user.update({
      where: { id: challenge.userId },
      data: { passwordHash },
    });
    await this.sessions.revokeAll(challenge.userId);
    return { ok: true };
  }

  async refresh(refreshToken: string) {
    const result = await this.sessions.refresh(refreshToken);
    return {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      ...this.sessions.accountView(result.user),
    };
  }

  async me(accountId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: accountId },
    });
    return this.sessions.accountView(user);
  }

  async attachPhoneChallenge(
    accountId: string,
    phoneRaw: string,
    originFingerprint?: string,
  ) {
    const phone = normalizePhone(phoneRaw);
    const conflict = await this.prisma.user.findUnique({
      where: { phoneE164: phone },
    });
    if (conflict && conflict.id !== accountId) {
      throw new AppError('AUTH_CONFLICT', 409);
    }
    return this.challenges.createChallenge({
      purpose: ChallengePurpose.PHONE_ATTACH,
      destinationType: 'PHONE',
      destinationNormalized: phone,
      userId: accountId,
      originFingerprint,
    });
  }

  async verifyAttachPhone(
    accountId: string,
    challengeId: string,
    codeRaw: string,
  ) {
    const challenge = await this.challenges.consumeChallenge(
      challengeId,
      toLatinDigits(codeRaw).trim(),
    );
    if (
      challenge.purpose !== ChallengePurpose.PHONE_ATTACH ||
      challenge.userId !== accountId
    ) {
      throw new AppError('AUTH_CHALLENGE_INVALID', 400);
    }
    try {
      const user = await this.prisma.user.update({
        where: { id: accountId },
        data: { phoneE164: challenge.destinationNormalized },
      });
      return this.sessions.accountView(user);
    } catch {
      throw new AppError('AUTH_CONFLICT', 409);
    }
  }

  async removePhone(accountId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: accountId },
    });
    const hasVerifiedEmail = Boolean(
      user.emailNormalized && user.emailVerifiedAt,
    );
    if (!hasVerifiedEmail) throw new AppError('AUTH_LAST_CREDENTIAL', 400);
    return this.sessions.accountView(
      await this.prisma.user.update({
        where: { id: accountId },
        data: { phoneE164: null },
      }),
    );
  }

  async attachEmailChallenge(
    accountId: string,
    emailRaw: string,
    password: string,
    originFingerprint?: string,
  ) {
    const email = normalizeEmail(emailRaw);
    assertPasswordPolicy(password);
    const conflict = await this.prisma.user.findFirst({
      where: {
        emailNormalized: email,
        emailVerifiedAt: { not: null },
        NOT: { id: accountId },
      },
    });
    if (conflict) {
      throw new AppError('AUTH_CONFLICT', 409);
    }
    const passwordHash = await hashPassword(
      password,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );
    // Do not mutate the active verified credential until verification succeeds.
    return this.challenges.createChallenge({
      purpose: ChallengePurpose.EMAIL_ATTACH,
      destinationType: 'EMAIL',
      destinationNormalized: email,
      userId: accountId,
      pendingPasswordHash: passwordHash,
      pendingEmailDisplay: emailRaw.trim(),
      originFingerprint,
    });
  }

  async verifyAttachEmail(
    accountId: string,
    challengeId: string,
    codeRaw: string,
  ) {
    const challenge = await this.challenges.consumeChallenge(
      challengeId,
      toLatinDigits(codeRaw).trim(),
    );
    if (
      challenge.purpose !== ChallengePurpose.EMAIL_ATTACH ||
      challenge.userId !== accountId ||
      !challenge.pendingPasswordHash
    ) {
      throw new AppError('AUTH_CHALLENGE_INVALID', 400);
    }

    const conflict = await this.prisma.user.findFirst({
      where: {
        emailNormalized: challenge.destinationNormalized,
        emailVerifiedAt: { not: null },
        NOT: { id: accountId },
      },
    });
    if (conflict) {
      throw new AppError('AUTH_CONFLICT', 409);
    }

    try {
      const user = await this.prisma.user.update({
        where: { id: accountId },
        data: {
          emailNormalized: challenge.destinationNormalized,
          emailDisplay:
            challenge.pendingEmailDisplay ?? challenge.destinationNormalized,
          passwordHash: challenge.pendingPasswordHash,
          emailVerifiedAt: new Date(),
        },
      });
      return this.sessions.accountView(user);
    } catch {
      throw new AppError('AUTH_CONFLICT', 409);
    }
  }

  async removeEmail(accountId: string) {
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: accountId },
    });
    if (!user.phoneE164) throw new AppError('AUTH_LAST_CREDENTIAL', 400);
    return this.sessions.accountView(
      await this.prisma.user.update({
        where: { id: accountId },
        data: {
          emailNormalized: null,
          emailDisplay: null,
          passwordHash: null,
          emailVerifiedAt: null,
        },
      }),
    );
  }

  async changePassword(
    accountId: string,
    currentPassword: string,
    newPassword: string,
  ) {
    assertPasswordPolicy(newPassword);
    const user = await this.prisma.user.findUniqueOrThrow({
      where: { id: accountId },
    });
    if (!user.passwordHash || !user.emailVerifiedAt) {
      throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
    }
    const verified = await verifyPassword(
      user.passwordHash,
      currentPassword,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );
    if (!verified.ok) throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
    const passwordHash = await hashPassword(
      newPassword,
      this.config.getOrThrow('PASSWORD_PEPPER'),
    );
    await this.prisma.user.update({
      where: { id: accountId },
      data: { passwordHash },
    });
    await this.sessions.revokeAll(accountId);
    return { ok: true };
  }
}

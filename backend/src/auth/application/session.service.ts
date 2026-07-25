import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Prisma,
  AuthChallenge,
  ChallengePurpose,
  DestinationType,
  User,
} from '@prisma/client';
import {
  importPKCS8,
  importSPKI,
  exportJWK,
  SignJWT,
  jwtVerify,
  JWK,
} from 'jose';
import { PrismaService } from '../../database/prisma.service';
import { AppError } from '../../common/errors/app-error';
import {
  generateOtpCode,
  generateRefreshToken,
  hashOpaqueSecret,
  loadPem,
  maskPhone,
  randomUuid,
  safeEqualHex,
} from '../../common/security/crypto.util';
import {
  destinationRateLimitBucketKey,
  fingerprintOrigin,
} from '../../common/security/origin.util';
import { SMS_DELIVERY_PORT } from '../delivery/delivery.ports';
import type { SmsDeliveryPort } from '../delivery/delivery.ports';

const ACCESS_TTL_SEC = 10 * 60;
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const CHALLENGE_TTL_MS = 5 * 60 * 1000;
const RESEND_MS = 60 * 1000;
const TX_RETRY_LIMIT = 3;

@Injectable()
export class TokenService {
  private privateKey!: CryptoKey;
  private publicKey!: CryptoKey;
  private publicJwk!: JWK;

  constructor(private readonly config: ConfigService) {}

  async init() {
    const privatePem = loadPem(this.config.getOrThrow('JWT_PRIVATE_KEY_PATH'));
    const publicPem = loadPem(this.config.getOrThrow('JWT_PUBLIC_KEY_PATH'));
    this.privateKey = await importPKCS8(privatePem, 'RS256');
    this.publicKey = await importSPKI(publicPem, 'RS256');
    this.publicJwk = await exportJWK(this.publicKey);
    this.publicJwk.kid = this.config.getOrThrow('JWT_ACTIVE_KID');
    this.publicJwk.alg = 'RS256';
    this.publicJwk.use = 'sig';
  }

  jwks() {
    return { keys: [this.publicJwk] };
  }

  async issueAccessToken(params: {
    accountId: string;
    sessionId: string;
  }): Promise<string> {
    const kid = this.config.getOrThrow<string>('JWT_ACTIVE_KID');
    return new SignJWT({
      sid: params.sessionId,
    })
      .setProtectedHeader({ alg: 'RS256', kid })
      .setSubject(params.accountId)
      .setIssuer(this.config.getOrThrow('JWT_ISSUER'))
      .setAudience(this.config.getOrThrow('JWT_AUDIENCE'))
      .setJti(randomUuid())
      .setIssuedAt()
      .setExpirationTime(`${ACCESS_TTL_SEC}s`)
      .sign(this.privateKey);
  }

  async verifyAccessToken(token: string) {
    const { payload, protectedHeader } = await jwtVerify(
      token,
      this.publicKey,
      {
        issuer: this.config.getOrThrow('JWT_ISSUER'),
        audience: this.config.getOrThrow('JWT_AUDIENCE'),
        algorithms: ['RS256'],
      },
    );
    if (!protectedHeader.kid) {
      throw new AppError('AUTH_INVALID_TOKEN', 401);
    }
    return payload;
  }
}

type AuthorizeChallengeOutcome<T> =
  | { status: 'ok'; value: T }
  | {
      status: 'error';
      code:
        'AUTH_CHALLENGE_EXPIRED' | 'AUTH_CHALLENGE_INVALID' | 'AUTH_CONFLICT';
    };

type RefreshOutcome =
  | {
      status: 'ok';
      accessToken: string;
      refreshToken: string;
      user: User;
    }
  | { status: 'error'; code: 'AUTH_SESSION_REVOKED' };

function isRetryableTxError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;
  const code = (error as { code?: string }).code;
  return code === 'P2034' || code === '40001';
}

function isUniqueConflict(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    (error as { code?: string }).code === 'P2002'
  );
}

@Injectable()
export class ChallengeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    @Inject(SMS_DELIVERY_PORT) private readonly sms: SmsDeliveryPort,
  ) {}

  async createChallenge(input: {
    purpose: ChallengePurpose;
    destinationType: DestinationType;
    destinationNormalized: string;
    userId?: string;
    originFingerprint?: string;
  }) {
    await this.enforceRateLimit(
      destinationRateLimitBucketKey({
        destinationType: input.destinationType,
        destinationNormalized: input.destinationNormalized,
        purpose: input.purpose,
        pepper: this.config.getOrThrow('RATE_LIMIT_PEPPER'),
      }),
      5,
      15 * 60 * 1000,
    );
    if (input.originFingerprint) {
      await this.enforceRateLimit(
        `challenge:origin:${input.originFingerprint}`,
        30,
        15 * 60 * 1000,
      );
    }

    const latest = await this.prisma.authChallenge.findFirst({
      where: {
        destinationNormalized: input.destinationNormalized,
        purpose: input.purpose,
        consumedAt: null,
        expiresAt: { gt: new Date() },
      },
      orderBy: { createdAt: 'desc' },
    });
    if (latest && Date.now() - latest.createdAt.getTime() < RESEND_MS) {
      throw new AppError('AUTH_RATE_LIMITED', 429);
    }

    // Invalidate older active challenges; do not reset rate-limit counters.
    await this.prisma.authChallenge.updateMany({
      where: {
        destinationNormalized: input.destinationNormalized,
        purpose: input.purpose,
        consumedAt: null,
      },
      data: { expiresAt: new Date() },
    });

    const code = generateOtpCode();
    const codeHash = hashOpaqueSecret(
      code,
      this.config.getOrThrow('OTP_CODE_PEPPER'),
    );
    const expiresAt = new Date(Date.now() + CHALLENGE_TTL_MS);
    const challenge = await this.prisma.authChallenge.create({
      data: {
        purpose: input.purpose,
        destinationType: input.destinationType,
        destinationNormalized: input.destinationNormalized,
        codeHash,
        expiresAt,
        userId: input.userId,
      },
    });

    await this.sms.sendOtp({
      destinationE164: input.destinationNormalized,
      purpose: input.purpose,
      code,
      expiresAt,
    });

    return {
      challengeId: challenge.id,
      maskedDestination: maskPhone(input.destinationNormalized),
      resendAvailableAt: new Date(Date.now() + RESEND_MS).toISOString(),
      expiresAt: challenge.expiresAt.toISOString(),
    };
  }

  /**
   * Validate a challenge and run the authorized mutation in one transaction.
   * Consumption commits only after `action` succeeds. Error outcomes map to
   * AppError only after the transaction commits or rolls back.
   */
  async authorizeChallenge<T>(
    input: {
      challengeId: string;
      code: string;
      purpose: ChallengePurpose;
      accountId?: string;
      requireBoundUser?: boolean;
    },
    action: (
      tx: Prisma.TransactionClient,
      challenge: AuthChallenge,
    ) => Promise<T>,
  ): Promise<T> {
    let outcome: AuthorizeChallengeOutcome<T>;
    try {
      outcome = await this.withTxRetry(() =>
        this.prisma.$transaction(async (tx) => {
          await tx.$executeRaw`
            SELECT id FROM auth_challenges WHERE id = ${input.challengeId}::uuid FOR UPDATE
          `;
          const challenge = await tx.authChallenge.findUnique({
            where: { id: input.challengeId },
          });
          if (
            !challenge ||
            challenge.consumedAt ||
            challenge.expiresAt <= new Date()
          ) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_EXPIRED',
            } satisfies AuthorizeChallengeOutcome<T>;
          }
          if (challenge.attempts >= challenge.maxAttempts) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_INVALID',
            } satisfies AuthorizeChallengeOutcome<T>;
          }
          // Purpose / ownership / pending checks before authorizing mutation.
          if (challenge.purpose !== input.purpose) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_INVALID',
            } satisfies AuthorizeChallengeOutcome<T>;
          }
          if (
            input.accountId !== undefined &&
            challenge.userId !== input.accountId
          ) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_INVALID',
            } satisfies AuthorizeChallengeOutcome<T>;
          }
          if (input.requireBoundUser && !challenge.userId) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_INVALID',
            } satisfies AuthorizeChallengeOutcome<T>;
          }

          const actual = hashOpaqueSecret(
            input.code,
            this.config.getOrThrow('OTP_CODE_PEPPER'),
          );
          if (!safeEqualHex(challenge.codeHash, actual)) {
            await tx.authChallenge.update({
              where: { id: input.challengeId },
              data: { attempts: { increment: 1 } },
            });
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_INVALID',
            } satisfies AuthorizeChallengeOutcome<T>;
          }

          // On P2002, Prisma aborts the TX; outer catch maps to AUTH_CONFLICT.
          const value = await action(tx, challenge);

          const updated = await tx.authChallenge.updateMany({
            where: {
              id: input.challengeId,
              consumedAt: null,
              attempts: { lt: challenge.maxAttempts },
            },
            data: { consumedAt: new Date() },
          });
          if (updated.count !== 1) {
            return {
              status: 'error',
              code: 'AUTH_CHALLENGE_EXPIRED',
            } satisfies AuthorizeChallengeOutcome<T>;
          }
          return {
            status: 'ok',
            value,
          } satisfies AuthorizeChallengeOutcome<T>;
        }),
      );
    } catch (error) {
      if (isUniqueConflict(error)) {
        outcome = {
          status: 'error',
          code: 'AUTH_CONFLICT',
        };
      } else {
        throw error;
      }
    }

    if (outcome.status === 'error') {
      const httpStatus = outcome.code === 'AUTH_CONFLICT' ? 409 : 400;
      throw new AppError(outcome.code, httpStatus);
    }
    return outcome.value;
  }

  async enforceRateLimit(bucketKey: string, limit: number, windowMs: number) {
    const limited = await this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${bucketKey}))`;
      const now = new Date();
      const bucket = await tx.rateLimitBucket.findUnique({
        where: { bucketKey },
      });
      if (!bucket || now.getTime() - bucket.windowStart.getTime() > windowMs) {
        await tx.rateLimitBucket.upsert({
          where: { bucketKey },
          create: { bucketKey, windowStart: now, count: 1 },
          update: { windowStart: now, count: 1 },
        });
        return false;
      }
      if (bucket.count >= limit) {
        return true;
      }
      await tx.rateLimitBucket.update({
        where: { bucketKey },
        data: { count: { increment: 1 } },
      });
      return false;
    });
    if (limited) {
      throw new AppError('AUTH_RATE_LIMITED', 429);
    }
  }

  originFingerprintFromRaw(rawOrigin: string | undefined): string | undefined {
    if (!rawOrigin) return undefined;
    return fingerprintOrigin(
      rawOrigin,
      this.config.getOrThrow('RATE_LIMIT_PEPPER'),
    );
  }

  private async withTxRetry<T>(fn: () => Promise<T>): Promise<T> {
    let lastError: unknown;
    for (let attempt = 0; attempt < TX_RETRY_LIMIT; attempt += 1) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        if (!isRetryableTxError(error) || attempt === TX_RETRY_LIMIT - 1) {
          throw error;
        }
      }
    }
    throw lastError;
  }
}

@Injectable()
export class SessionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly tokens: TokenService,
  ) {}

  async createSessionRecords(
    tx: Prisma.TransactionClient,
    userId: string,
    deviceLabel?: string,
  ): Promise<{ sessionId: string; refreshToken: string; userId: string }> {
    const familyId = randomUuid();
    const refresh = generateRefreshToken();
    const tokenHash = hashOpaqueSecret(
      refresh,
      this.config.getOrThrow('REFRESH_TOKEN_PEPPER'),
    );
    const absoluteExpiresAt = new Date(Date.now() + REFRESH_TTL_MS);
    const session = await tx.authSession.create({
      data: {
        userId,
        familyId,
        absoluteExpiresAt,
        deviceLabel,
        refreshTokens: {
          create: {
            tokenHash,
            familyId,
            expiresAt: absoluteExpiresAt,
          },
        },
      },
    });
    return {
      sessionId: session.id,
      refreshToken: refresh,
      userId,
    };
  }

  async issueSessionTokens(records: {
    sessionId: string;
    refreshToken: string;
    userId: string;
  }) {
    const accessToken = await this.tokens.issueAccessToken({
      accountId: records.userId,
      sessionId: records.sessionId,
    });
    return {
      accessToken,
      refreshToken: records.refreshToken,
      sessionId: records.sessionId,
    };
  }

  /** Convenience for non-challenge flows (email sign-in, etc.). */
  async createSession(userId: string, deviceLabel?: string) {
    const records = await this.prisma.$transaction((tx) =>
      this.createSessionRecords(tx, userId, deviceLabel),
    );
    return this.issueSessionTokens(records);
  }

  async refresh(refreshToken: string) {
    const tokenHash = hashOpaqueSecret(
      refreshToken,
      this.config.getOrThrow('REFRESH_TOKEN_PEPPER'),
    );

    const outcome = await this.withTxRetry(() =>
      this.prisma.$transaction(async (tx) => {
        await tx.$executeRaw`
          SELECT id FROM refresh_tokens WHERE token_hash = ${tokenHash} FOR UPDATE
        `;
        const existing = await tx.refreshToken.findUnique({
          where: { tokenHash },
          include: { session: { include: { user: true } } },
        });
        if (!existing) {
          return {
            status: 'error',
            code: 'AUTH_SESSION_REVOKED',
          } satisfies RefreshOutcome;
        }

        const unusable =
          existing.usedAt ||
          existing.revokedAt ||
          existing.expiresAt <= new Date() ||
          existing.session.revokedAt ||
          existing.session.absoluteExpiresAt <= new Date() ||
          existing.session.user.disabledAt;

        if (unusable) {
          await tx.authSession.updateMany({
            where: { familyId: existing.familyId },
            data: { revokedAt: new Date() },
          });
          await tx.refreshToken.updateMany({
            where: { familyId: existing.familyId },
            data: { revokedAt: new Date() },
          });
          await tx.securityEvent.create({
            data: {
              type: 'REFRESH_REPLAY',
              accountId: existing.session.userId,
              sessionId: existing.sessionId,
              metadataJson: {},
            },
          });
          return {
            status: 'error',
            code: 'AUTH_SESSION_REVOKED',
          } satisfies RefreshOutcome;
        }

        // Atomic claim — only one concurrent request can mark this row used.
        const claimed = await tx.refreshToken.updateMany({
          where: {
            id: existing.id,
            usedAt: null,
            revokedAt: null,
          },
          data: { usedAt: new Date() },
        });
        if (claimed.count !== 1) {
          await tx.authSession.updateMany({
            where: { familyId: existing.familyId },
            data: { revokedAt: new Date() },
          });
          await tx.refreshToken.updateMany({
            where: { familyId: existing.familyId },
            data: { revokedAt: new Date() },
          });
          await tx.securityEvent.create({
            data: {
              type: 'REFRESH_REPLAY',
              accountId: existing.session.userId,
              sessionId: existing.sessionId,
              metadataJson: {},
            },
          });
          return {
            status: 'error',
            code: 'AUTH_SESSION_REVOKED',
          } satisfies RefreshOutcome;
        }

        const nextRefresh = generateRefreshToken();
        const nextHash = hashOpaqueSecret(
          nextRefresh,
          this.config.getOrThrow('REFRESH_TOKEN_PEPPER'),
        );
        const replacement = await tx.refreshToken.create({
          data: {
            sessionId: existing.sessionId,
            tokenHash: nextHash,
            familyId: existing.familyId,
            expiresAt: existing.session.absoluteExpiresAt,
          },
        });
        await tx.refreshToken.update({
          where: { id: existing.id },
          data: { replacedById: replacement.id },
        });
        await tx.authSession.update({
          where: { id: existing.sessionId },
          data: { lastSeenAt: new Date() },
        });

        const accessToken = await this.tokens.issueAccessToken({
          accountId: existing.session.userId,
          sessionId: existing.sessionId,
        });
        return {
          status: 'ok',
          accessToken,
          refreshToken: nextRefresh,
          user: existing.session.user,
        } satisfies RefreshOutcome;
      }),
    );

    if (outcome.status === 'error') {
      throw new AppError(outcome.code, 401);
    }
    return outcome;
  }

  async assertSessionActive(sessionId: string, accountId: string) {
    const session = await this.prisma.authSession.findUnique({
      where: { id: sessionId },
      include: { user: true },
    });
    if (
      !session ||
      session.userId !== accountId ||
      session.revokedAt ||
      session.absoluteExpiresAt <= new Date() ||
      session.user.disabledAt
    ) {
      throw new AppError('AUTH_SESSION_REVOKED', 401);
    }
    return session;
  }

  async revokeSession(sessionId: string, accountId: string) {
    const session = await this.prisma.authSession.findFirst({
      where: { id: sessionId, userId: accountId },
    });
    if (!session) throw new AppError('NOT_FOUND', 404);
    await this.prisma.$transaction([
      this.prisma.authSession.update({
        where: { id: sessionId },
        data: { revokedAt: new Date() },
      }),
      this.prisma.refreshToken.updateMany({
        where: { sessionId },
        data: { revokedAt: new Date() },
      }),
    ]);
  }

  async revokeAll(accountId: string) {
    const sessions = await this.prisma.authSession.findMany({
      where: { userId: accountId, revokedAt: null },
    });
    const ids = sessions.map((s) => s.id);
    await this.prisma.$transaction([
      this.prisma.authSession.updateMany({
        where: { userId: accountId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
      this.prisma.refreshToken.updateMany({
        where: { sessionId: { in: ids } },
        data: { revokedAt: new Date() },
      }),
    ]);
  }

  accountView(user: { id: string }) {
    return {
      accountId: user.id,
    };
  }

  private async withTxRetry<T>(fn: () => Promise<T>): Promise<T> {
    let lastError: unknown;
    for (let attempt = 0; attempt < TX_RETRY_LIMIT; attempt += 1) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        if (!isRetryableTxError(error) || attempt === TX_RETRY_LIMIT - 1) {
          throw error;
        }
      }
    }
    throw lastError;
  }
}

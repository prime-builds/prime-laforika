import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ChallengePurpose, DestinationType, Prisma } from '@prisma/client';
import { importPKCS8, importSPKI, exportJWK, SignJWT, jwtVerify, JWK } from 'jose';
import { PrismaService } from '../../database/prisma.service';
import { AppError } from '../../common/errors/app-error';
import {
  generateOtpCode,
  generateRefreshToken,
  hashOpaqueSecret,
  loadPem,
  maskEmail,
  maskPhone,
  randomUuid,
  safeEqualHex,
} from '../../common/security/crypto.util';

const ACCESS_TTL_SEC = 10 * 60;
const REFRESH_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const CHALLENGE_TTL_MS = 5 * 60 * 1000;
const RESEND_MS = 60 * 1000;

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
    const { payload, protectedHeader } = await jwtVerify(token, this.publicKey, {
      issuer: this.config.getOrThrow('JWT_ISSUER'),
      audience: this.config.getOrThrow('JWT_AUDIENCE'),
      algorithms: ['RS256'],
    });
    if (!protectedHeader.kid) {
      throw new AppError('AUTH_INVALID_TOKEN', 401);
    }
    return payload;
  }
}

@Injectable()
export class ChallengeService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async createChallenge(input: {
    purpose: ChallengePurpose;
    destinationType: DestinationType;
    destinationNormalized: string;
    userId?: string;
  }) {
    await this.enforceRateLimit(
      `challenge:${input.destinationType}:${input.destinationNormalized}:${input.purpose}`,
      5,
      15 * 60 * 1000,
    );

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
    const challenge = await this.prisma.authChallenge.create({
      data: {
        purpose: input.purpose,
        destinationType: input.destinationType,
        destinationNormalized: input.destinationNormalized,
        codeHash,
        expiresAt: new Date(Date.now() + CHALLENGE_TTL_MS),
        userId: input.userId,
      },
    });

    const fixtureEnabled = this.config.get<boolean>('FIXTURE_DELIVERY_ENABLED');
    if (fixtureEnabled) {
      await this.prisma.fixtureInboxMessage.create({
        data: {
          channel: input.destinationType === 'PHONE' ? 'SMS' : 'EMAIL',
          destinationNormalized: input.destinationNormalized,
          purpose: input.purpose,
          code,
          payloadJson: {},
        },
      });
    } else {
      throw new AppError('DELIVERY_UNAVAILABLE', 503);
    }

    return {
      challengeId: challenge.id,
      maskedDestination:
        input.destinationType === 'PHONE'
          ? maskPhone(input.destinationNormalized)
          : maskEmail(input.destinationNormalized),
      resendAvailableAt: new Date(Date.now() + RESEND_MS).toISOString(),
      expiresAt: challenge.expiresAt.toISOString(),
    };
  }

  async consumeChallenge(challengeId: string, code: string) {
    return this.prisma.$transaction(async (tx) => {
      const challenge = await tx.authChallenge.findUnique({
        where: { id: challengeId },
      });
      if (!challenge || challenge.consumedAt || challenge.expiresAt <= new Date()) {
        throw new AppError('AUTH_CHALLENGE_EXPIRED', 400);
      }
      if (challenge.attempts >= challenge.maxAttempts) {
        throw new AppError('AUTH_CHALLENGE_INVALID', 400);
      }
      const expected = challenge.codeHash;
      const actual = hashOpaqueSecret(
        code,
        this.config.getOrThrow('OTP_CODE_PEPPER'),
      );
      if (!safeEqualHex(expected, actual)) {
        await tx.authChallenge.update({
          where: { id: challengeId },
          data: { attempts: { increment: 1 } },
        });
        throw new AppError('AUTH_CHALLENGE_INVALID', 400);
      }
      const updated = await tx.authChallenge.updateMany({
        where: { id: challengeId, consumedAt: null },
        data: { consumedAt: new Date() },
      });
      if (updated.count !== 1) {
        throw new AppError('AUTH_CHALLENGE_EXPIRED', 400);
      }
      return challenge;
    });
  }

  async enforceRateLimit(bucketKey: string, limit: number, windowMs: number) {
    const now = new Date();
    const bucket = await this.prisma.rateLimitBucket.findUnique({
      where: { bucketKey },
    });
    if (!bucket || now.getTime() - bucket.windowStart.getTime() > windowMs) {
      await this.prisma.rateLimitBucket.upsert({
        where: { bucketKey },
        create: { bucketKey, windowStart: now, count: 1 },
        update: { windowStart: now, count: 1 },
      });
      return;
    }
    if (bucket.count >= limit) {
      throw new AppError('AUTH_RATE_LIMITED', 429);
    }
    await this.prisma.rateLimitBucket.update({
      where: { bucketKey },
      data: { count: { increment: 1 } },
    });
  }
}

@Injectable()
export class SessionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly tokens: TokenService,
  ) {}

  async createSession(userId: string, deviceLabel?: string) {
    const familyId = randomUuid();
    const refresh = generateRefreshToken();
    const tokenHash = hashOpaqueSecret(
      refresh,
      this.config.getOrThrow('REFRESH_TOKEN_PEPPER'),
    );
    const absoluteExpiresAt = new Date(Date.now() + REFRESH_TTL_MS);
    const session = await this.prisma.authSession.create({
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
    const accessToken = await this.tokens.issueAccessToken({
      accountId: userId,
      sessionId: session.id,
    });
    return { accessToken, refreshToken: refresh, sessionId: session.id };
  }

  async refresh(refreshToken: string) {
    const tokenHash = hashOpaqueSecret(
      refreshToken,
      this.config.getOrThrow('REFRESH_TOKEN_PEPPER'),
    );

    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.refreshToken.findUnique({
        where: { tokenHash },
        include: { session: { include: { user: true } } },
      });
      if (!existing) {
        throw new AppError('AUTH_SESSION_REVOKED', 401);
      }
      if (
        existing.usedAt ||
        existing.revokedAt ||
        existing.expiresAt <= new Date() ||
        existing.session.revokedAt ||
        existing.session.absoluteExpiresAt <= new Date() ||
        existing.session.user.disabledAt
      ) {
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
        throw new AppError('AUTH_SESSION_REVOKED', 401);
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
        data: { usedAt: new Date(), replacedById: replacement.id },
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
        accessToken,
        refreshToken: nextRefresh,
        user: existing.session.user,
      };
    });
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

  accountView(user: {
    id: string;
    phoneE164: string | null;
    emailNormalized: string | null;
  }) {
    return {
      accountId: user.id,
      hasPhone: Boolean(user.phoneE164),
      hasEmail: Boolean(user.emailNormalized),
      maskedPhone: user.phoneE164 ? maskPhone(user.phoneE164) : null,
      maskedEmail: user.emailNormalized ? maskEmail(user.emailNormalized) : null,
    };
  }
}

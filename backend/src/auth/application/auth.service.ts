import { Injectable } from '@nestjs/common';
import { ChallengePurpose } from '@prisma/client';
import { PrismaService } from '../../database/prisma.service';
import { AppError } from '../../common/errors/app-error';
import {
  normalizePhone,
  toLatinDigits,
} from '../../common/security/crypto.util';
import { ChallengeService, SessionService } from './session.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
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
    const result = await this.challenges.authorizeChallenge(
      {
        challengeId,
        code,
        purpose: ChallengePurpose.PHONE_SIGN_IN,
      },
      async (tx, challenge) => {
        let user = await tx.user.findUnique({
          where: { phoneE164: challenge.destinationNormalized },
        });
        if (!user) {
          user = await tx.user.create({
            data: { phoneE164: challenge.destinationNormalized },
          });
        }
        if (user.disabledAt) {
          throw new AppError('AUTH_INVALID_CREDENTIALS', 401);
        }
        const sessionRecords = await this.sessions.createSessionRecords(
          tx,
          user.id,
        );
        return { user, sessionRecords };
      },
    );
    const tokens = await this.sessions.issueSessionTokens(
      result.sessionRecords,
    );
    return { ...tokens, ...this.sessions.accountView(result.user) };
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
}

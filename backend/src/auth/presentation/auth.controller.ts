import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiExtraModels,
  ApiOkResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import type { Request } from 'express';
import { AuthService } from '../application/auth.service';
import {
  ChallengeService,
  SessionService,
  TokenService,
} from '../application/session.service';
import { AccessTokenGuard } from '../../common/guards/access-token.guard';
import { PrismaService } from '../../database/prisma.service';
import { resolveRequestOrigin } from '../../common/security/origin.util';
import { ApiAuthErrors } from './api-error-responses.decorator';
import {
  AccountViewDto,
  ChallengeResponseDto,
  CodeDto,
  ErrorResponseDto,
  HealthResponseDto,
  OkResponseDto,
  PhoneDto,
  RefreshDto,
  SessionListItemDto,
  TokenResponseDto,
} from './auth.dto';

@ApiTags('auth')
@ApiExtraModels(ErrorResponseDto)
@Controller()
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly sessions: SessionService,
    private readonly challenges: ChallengeService,
    private readonly tokens: TokenService,
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  private originFingerprint(req: Request): string | undefined {
    const trust = this.config.get<boolean>('TRUST_FORWARDED_ORIGIN') ?? false;
    const raw = resolveRequestOrigin(req, trust);
    return this.challenges.originFingerprintFromRaw(raw);
  }

  @Get('health')
  @ApiOkResponse({ type: HealthResponseDto })
  health() {
    return { status: 'ok' };
  }

  @Get('auth/jwks')
  jwks() {
    return this.tokens.jwks();
  }

  @Post('auth/phone/challenges')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: ChallengeResponseDto })
  @ApiAuthErrors(400, 429, 503)
  requestPhone(@Req() req: Request, @Body() body: PhoneDto) {
    return this.auth.requestPhoneChallenge(
      body.phone,
      this.originFingerprint(req),
    );
  }

  @Post('auth/phone/challenges/:challengeId/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TokenResponseDto })
  @ApiAuthErrors(400, 401)
  verifyPhone(
    @Param('challengeId') challengeId: string,
    @Body() body: CodeDto,
  ) {
    return this.auth.verifyPhoneChallenge(challengeId, body.code);
  }

  @Post('auth/refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TokenResponseDto })
  @ApiAuthErrors(400, 401)
  refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken);
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Get('account/me')
  @ApiOkResponse({ type: AccountViewDto })
  @ApiAuthErrors(401)
  me(@Req() req: { auth: { accountId: string } }) {
    return this.auth.me(req.auth.accountId);
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Get('auth/sessions')
  @ApiOkResponse({ type: SessionListItemDto, isArray: true })
  @ApiAuthErrors(401)
  async listSessions(
    @Req() req: { auth: { accountId: string; sessionId: string } },
  ) {
    const sessions = await this.prisma.authSession.findMany({
      where: { userId: req.auth.accountId },
      orderBy: { createdAt: 'desc' },
    });
    return sessions.map((s) => ({
      sessionId: s.id,
      createdAt: s.createdAt.toISOString(),
      lastSeenAt: s.lastSeenAt.toISOString(),
      isCurrent: s.id === req.auth.sessionId,
      deviceLabel: s.deviceLabel,
      revoked: Boolean(s.revokedAt),
    }));
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Delete('auth/sessions/:sessionId')
  @ApiOkResponse({ type: OkResponseDto })
  @ApiAuthErrors(401, 404)
  revokeSession(
    @Req() req: { auth: { accountId: string } },
    @Param('sessionId') sessionId: string,
  ) {
    return this.sessions.revokeSession(sessionId, req.auth.accountId);
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Post('auth/logout')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: OkResponseDto })
  @ApiAuthErrors(401)
  async logout(@Req() req: { auth: { accountId: string; sessionId: string } }) {
    await this.sessions.revokeSession(req.auth.sessionId, req.auth.accountId);
    return { ok: true };
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Post('auth/logout-all')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: OkResponseDto })
  @ApiAuthErrors(401)
  async logoutAll(@Req() req: { auth: { accountId: string } }) {
    await this.sessions.revokeAll(req.auth.accountId);
    return { ok: true };
  }
}

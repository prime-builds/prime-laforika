import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Put,
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
  AttachEmailDto,
  ChallengeResponseDto,
  ChangePasswordDto,
  CodeDto,
  EmailSignInDto,
  EmailSignUpDto,
  EmailVerifyDto,
  ErrorResponseDto,
  HealthResponseDto,
  OkResponseDto,
  PhoneDto,
  RefreshDto,
  ResetChallengeDto,
  ResetPasswordDto,
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

  @Post('auth/email/sign-up')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: ChallengeResponseDto })
  @ApiAuthErrors(400, 409, 429, 503)
  emailSignUp(@Req() req: Request, @Body() body: EmailSignUpDto) {
    return this.auth.emailSignUp(
      body.email,
      body.password,
      this.originFingerprint(req),
    );
  }

  @Post('auth/email/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TokenResponseDto })
  @ApiAuthErrors(400, 401, 409)
  emailVerify(@Body() body: EmailVerifyDto) {
    return this.auth.emailVerify(body.challengeId, body.code);
  }

  @Post('auth/email/sign-in')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: TokenResponseDto })
  @ApiAuthErrors(400, 401)
  emailSignIn(@Body() body: EmailSignInDto) {
    return this.auth.emailSignIn(body.email, body.password);
  }

  @Post('auth/password/reset-challenges')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: ChallengeResponseDto })
  @ApiAuthErrors(400, 429, 503)
  resetChallenge(@Req() req: Request, @Body() body: ResetChallengeDto) {
    return this.auth.requestPasswordReset(
      body.email,
      this.originFingerprint(req),
    );
  }

  @Post('auth/password/reset')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: OkResponseDto })
  @ApiAuthErrors(400)
  resetPassword(@Body() body: ResetPasswordDto) {
    return this.auth.resetPassword(
      body.challengeId,
      body.code,
      body.newPassword,
    );
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
  @Post('account/phone/challenges')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: ChallengeResponseDto })
  @ApiAuthErrors(400, 401, 409, 429, 503)
  attachPhone(
    @Req() req: Request & { auth: { accountId: string } },
    @Body() body: PhoneDto,
  ) {
    return this.auth.attachPhoneChallenge(
      req.auth.accountId,
      body.phone,
      this.originFingerprint(req),
    );
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Post('account/phone/challenges/:challengeId/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: AccountViewDto })
  @ApiAuthErrors(400, 401, 409)
  verifyAttachPhone(
    @Req() req: { auth: { accountId: string } },
    @Param('challengeId') challengeId: string,
    @Body() body: CodeDto,
  ) {
    return this.auth.verifyAttachPhone(
      req.auth.accountId,
      challengeId,
      body.code,
    );
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Delete('account/phone')
  @ApiOkResponse({ type: AccountViewDto })
  @ApiAuthErrors(400, 401)
  removePhone(@Req() req: { auth: { accountId: string } }) {
    return this.auth.removePhone(req.auth.accountId);
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Post('account/email/challenges')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: ChallengeResponseDto })
  @ApiAuthErrors(400, 401, 409, 429, 503)
  attachEmail(
    @Req() req: Request & { auth: { accountId: string } },
    @Body() body: AttachEmailDto,
  ) {
    return this.auth.attachEmailChallenge(
      req.auth.accountId,
      body.email,
      body.password,
      this.originFingerprint(req),
    );
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Post('account/email/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: AccountViewDto })
  @ApiAuthErrors(400, 401, 409)
  verifyAttachEmail(
    @Req() req: { auth: { accountId: string } },
    @Body() body: EmailVerifyDto,
  ) {
    return this.auth.verifyAttachEmail(
      req.auth.accountId,
      body.challengeId,
      body.code,
    );
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Delete('account/email')
  @ApiOkResponse({ type: AccountViewDto })
  @ApiAuthErrors(400, 401)
  removeEmail(@Req() req: { auth: { accountId: string } }) {
    return this.auth.removeEmail(req.auth.accountId);
  }

  @ApiBearerAuth()
  @UseGuards(AccessTokenGuard)
  @Put('account/password')
  @ApiOkResponse({ type: OkResponseDto })
  @ApiAuthErrors(400, 401)
  changePassword(
    @Req() req: { auth: { accountId: string } },
    @Body() body: ChangePasswordDto,
  ) {
    return this.auth.changePassword(
      req.auth.accountId,
      body.currentPassword,
      body.newPassword,
    );
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

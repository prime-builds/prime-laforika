import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Put,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';
import { AuthService } from '../application/auth.service';
import { SessionService, TokenService } from '../application/session.service';
import { AccessTokenGuard } from '../../common/guards/access-token.guard';
import { PrismaService } from '../../database/prisma.service';
import { ConfigService } from '@nestjs/config';
import { AppError } from '../../common/errors/app-error';

class PhoneDto {
  @IsString()
  phone!: string;
}

class CodeDto {
  @IsString()
  code!: string;
}

class EmailSignUpDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(15)
  password!: string;
}

class EmailVerifyDto {
  @IsString()
  challengeId!: string;

  @IsString()
  code!: string;
}

class EmailSignInDto {
  @IsEmail()
  email!: string;

  @IsString()
  password!: string;
}

class ResetChallengeDto {
  @IsEmail()
  email!: string;
}

class ResetPasswordDto {
  @IsString()
  challengeId!: string;

  @IsString()
  code!: string;

  @IsString()
  @MinLength(15)
  newPassword!: string;
}

class RefreshDto {
  @IsString()
  refreshToken!: string;
}

class AttachEmailDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(15)
  password!: string;
}

class ChangePasswordDto {
  @IsString()
  currentPassword!: string;

  @IsString()
  @MinLength(15)
  newPassword!: string;
}

@ApiTags('auth')
@Controller()
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly sessions: SessionService,
    private readonly tokens: TokenService,
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  @Get('health')
  health() {
    return { status: 'ok' };
  }

  @Get('auth/jwks')
  jwks() {
    return this.tokens.jwks();
  }

  @Post('auth/phone/challenges')
  @HttpCode(HttpStatus.OK)
  requestPhone(@Body() body: PhoneDto) {
    return this.auth.requestPhoneChallenge(body.phone);
  }

  @Post('auth/phone/challenges/:challengeId/verify')
  @HttpCode(HttpStatus.OK)
  verifyPhone(@Param('challengeId') challengeId: string, @Body() body: CodeDto) {
    return this.auth.verifyPhoneChallenge(challengeId, body.code);
  }

  @Post('auth/email/sign-up')
  @HttpCode(HttpStatus.OK)
  emailSignUp(@Body() body: EmailSignUpDto) {
    return this.auth.emailSignUp(body.email, body.password);
  }

  @Post('auth/email/verify')
  @HttpCode(HttpStatus.OK)
  emailVerify(@Body() body: EmailVerifyDto) {
    return this.auth.emailVerify(body.challengeId, body.code);
  }

  @Post('auth/email/sign-in')
  @HttpCode(HttpStatus.OK)
  emailSignIn(@Body() body: EmailSignInDto) {
    return this.auth.emailSignIn(body.email, body.password);
  }

  @Post('auth/password/reset-challenges')
  @HttpCode(HttpStatus.OK)
  resetChallenge(@Body() body: ResetChallengeDto) {
    return this.auth.requestPasswordReset(body.email);
  }

  @Post('auth/password/reset')
  @HttpCode(HttpStatus.OK)
  resetPassword(@Body() body: ResetPasswordDto) {
    return this.auth.resetPassword(body.challengeId, body.code, body.newPassword);
  }

  @Post('auth/refresh')
  @HttpCode(HttpStatus.OK)
  refresh(@Body() body: RefreshDto) {
    return this.auth.refresh(body.refreshToken);
  }

  @UseGuards(AccessTokenGuard)
  @Get('account/me')
  me(@Req() req: { auth: { accountId: string } }) {
    return this.auth.me(req.auth.accountId);
  }

  @UseGuards(AccessTokenGuard)
  @Post('account/phone/challenges')
  attachPhone(
    @Req() req: { auth: { accountId: string } },
    @Body() body: PhoneDto,
  ) {
    return this.auth.attachPhoneChallenge(req.auth.accountId, body.phone);
  }

  @UseGuards(AccessTokenGuard)
  @Post('account/phone/challenges/:challengeId/verify')
  verifyAttachPhone(
    @Req() req: { auth: { accountId: string } },
    @Param('challengeId') challengeId: string,
    @Body() body: CodeDto,
  ) {
    return this.auth.verifyAttachPhone(req.auth.accountId, challengeId, body.code);
  }

  @UseGuards(AccessTokenGuard)
  @Delete('account/phone')
  removePhone(@Req() req: { auth: { accountId: string } }) {
    return this.auth.removePhone(req.auth.accountId);
  }

  @UseGuards(AccessTokenGuard)
  @Post('account/email/challenges')
  attachEmail(
    @Req() req: { auth: { accountId: string } },
    @Body() body: AttachEmailDto,
  ) {
    return this.auth.attachEmailChallenge(
      req.auth.accountId,
      body.email,
      body.password,
    );
  }

  @UseGuards(AccessTokenGuard)
  @Post('account/email/verify')
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

  @UseGuards(AccessTokenGuard)
  @Delete('account/email')
  removeEmail(@Req() req: { auth: { accountId: string } }) {
    return this.auth.removeEmail(req.auth.accountId);
  }

  @UseGuards(AccessTokenGuard)
  @Put('account/password')
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

  @UseGuards(AccessTokenGuard)
  @Get('auth/sessions')
  async listSessions(@Req() req: { auth: { accountId: string; sessionId: string } }) {
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

  @UseGuards(AccessTokenGuard)
  @Delete('auth/sessions/:sessionId')
  revokeSession(
    @Req() req: { auth: { accountId: string } },
    @Param('sessionId') sessionId: string,
  ) {
    return this.sessions.revokeSession(sessionId, req.auth.accountId);
  }

  @UseGuards(AccessTokenGuard)
  @Post('auth/logout')
  async logout(@Req() req: { auth: { accountId: string; sessionId: string } }) {
    await this.sessions.revokeSession(req.auth.sessionId, req.auth.accountId);
    return { ok: true };
  }

  @UseGuards(AccessTokenGuard)
  @Post('auth/logout-all')
  async logoutAll(@Req() req: { auth: { accountId: string } }) {
    await this.sessions.revokeAll(req.auth.accountId);
    return { ok: true };
  }

  @Get('dev/fixtures/inbox')
  async fixtureInbox(
    @Headers('x-fixture-key') key: string | undefined,
    @Query('destination') destination: string,
    @Query('purpose') purpose: string,
  ) {
    const env = this.config.get<string>('APP_ENVIRONMENT');
    if (env !== 'dev' && env !== 'test') {
      throw new AppError('NOT_FOUND', 404);
    }
    if (!this.config.get<boolean>('FIXTURE_DELIVERY_ENABLED')) {
      throw new AppError('NOT_FOUND', 404);
    }
    if (key !== this.config.get<string>('FIXTURE_INBOX_KEY')) {
      throw new AppError('AUTH_FORBIDDEN', 403);
    }
    const message = await this.prisma.fixtureInboxMessage.findFirst({
      where: {
        destinationNormalized: destination,
        purpose,
        consumedAt: null,
      },
      orderBy: { createdAt: 'desc' },
    });
    if (!message) return {};
    await this.prisma.fixtureInboxMessage.update({
      where: { id: message.id },
      data: { consumedAt: new Date() },
    });
    return {
      id: message.id,
      channel: message.channel,
      destinationNormalized: message.destinationNormalized,
      purpose: message.purpose,
      code: message.code,
      createdAt: message.createdAt.toISOString(),
    };
  }
}

import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import {
  SessionService,
  TokenService,
} from '../../auth/application/session.service';

@Injectable()
export class AccessTokenGuard implements CanActivate {
  constructor(
    private readonly tokens: TokenService,
    private readonly sessions: SessionService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      headers: { authorization?: string };
      auth?: { accountId: string; sessionId: string };
    }>();
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException();
    }
    try {
      const payload = await this.tokens.verifyAccessToken(header.slice(7));
      const accountId = String(payload.sub);
      const sessionId = String(payload.sid);
      await this.sessions.assertSessionActive(sessionId, accountId);
      request.auth = { accountId, sessionId };
      return true;
    } catch {
      throw new UnauthorizedException();
    }
  }
}

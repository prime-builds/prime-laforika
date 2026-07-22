import { Module, OnModuleInit } from '@nestjs/common';
import { AuthService } from './application/auth.service';
import {
  ChallengeService,
  SessionService,
  TokenService,
} from './application/session.service';
import { AuthController } from './presentation/auth.controller';
import { AccessTokenGuard } from '../common/guards/access-token.guard';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    ChallengeService,
    SessionService,
    TokenService,
    AccessTokenGuard,
  ],
  exports: [TokenService, SessionService, AuthService],
})
export class AuthModule implements OnModuleInit {
  constructor(private readonly tokens: TokenService) {}

  async onModuleInit() {
    await this.tokens.init();
  }
}

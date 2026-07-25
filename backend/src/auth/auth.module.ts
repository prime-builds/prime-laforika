import { DynamicModule, Module, OnModuleInit, Type } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './application/auth.service';
import {
  ChallengeService,
  SessionService,
  TokenService,
} from './application/session.service';
import { AuthController } from './presentation/auth.controller';
import { FixtureController } from './presentation/fixture.controller';
import { AccessTokenGuard } from '../common/guards/access-token.guard';
import { SMS_DELIVERY_PORT } from './delivery/delivery.ports';
import {
  FixtureInbox,
  FixtureSmsDelivery,
  UnavailableSmsDelivery,
} from './delivery/fixture.delivery';

function isFixtureDeliveryMode(env: {
  APP_ENVIRONMENT?: string;
  FIXTURE_DELIVERY_ENABLED?: string | boolean;
  DELIVERY_MODE?: string;
}): boolean {
  const appEnv = env.APP_ENVIRONMENT;
  if (appEnv !== 'dev' && appEnv !== 'test') {
    return false;
  }
  const enabled =
    env.FIXTURE_DELIVERY_ENABLED === true ||
    env.FIXTURE_DELIVERY_ENABLED === 'true';
  const mode = env.DELIVERY_MODE ?? (enabled ? 'fixture' : 'unavailable');
  return enabled && mode === 'fixture';
}

@Module({})
export class AuthModule implements OnModuleInit {
  constructor(private readonly tokens: TokenService) {}

  static forRoot(): DynamicModule {
    const fixtureMode = isFixtureDeliveryMode(process.env);
    const controllers: Type<unknown>[] = [AuthController];
    if (fixtureMode) {
      controllers.push(FixtureController);
    }

    return {
      module: AuthModule,
      controllers,
      providers: [
        AuthService,
        ChallengeService,
        SessionService,
        TokenService,
        AccessTokenGuard,
        FixtureInbox,
        {
          provide: SMS_DELIVERY_PORT,
          inject: [ConfigService, FixtureInbox],
          useFactory: (config: ConfigService, inbox: FixtureInbox) => {
            if (
              isFixtureDeliveryMode({
                APP_ENVIRONMENT: config.get<string>('APP_ENVIRONMENT'),
                FIXTURE_DELIVERY_ENABLED: config.get<boolean>(
                  'FIXTURE_DELIVERY_ENABLED',
                ),
                DELIVERY_MODE: config.get<string>('DELIVERY_MODE'),
              })
            ) {
              return new FixtureSmsDelivery(inbox);
            }
            return new UnavailableSmsDelivery();
          },
        },
      ],
      exports: [TokenService, SessionService, AuthService, FixtureInbox],
    };
  }

  async onModuleInit() {
    await this.tokens.init();
  }
}

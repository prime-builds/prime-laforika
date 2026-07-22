import { Controller, Get, Headers, Query } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiExcludeController } from '@nestjs/swagger';
import { AppError } from '../../common/errors/app-error';
import { constantTimeEqualString } from '../../common/security/origin.util';
import { FixtureInbox } from '../delivery/fixture.delivery';

@ApiExcludeController()
@Controller('dev/fixtures')
export class FixtureController {
  constructor(
    private readonly inbox: FixtureInbox,
    private readonly config: ConfigService,
  ) {}

  @Get('inbox')
  fixtureInbox(
    @Headers('x-fixture-key') key: string | undefined,
    @Query('destination') destination: string,
    @Query('purpose') purpose: string,
  ) {
    const expected = this.config.getOrThrow<string>('FIXTURE_INBOX_KEY');
    if (!key || !constantTimeEqualString(key, expected)) {
      throw new AppError('AUTH_FORBIDDEN', 403);
    }
    if (!destination || !purpose) {
      throw new AppError('VALIDATION_ERROR', 400);
    }

    const message = this.inbox.consume(destination, purpose);
    if (!message) {
      return {};
    }
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

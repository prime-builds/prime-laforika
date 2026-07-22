import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { AppError } from '../../common/errors/app-error';
import { EmailDeliveryPort, SmsDeliveryPort } from './delivery.ports';

export type FixtureInboxEntry = {
  id: string;
  channel: 'SMS' | 'EMAIL';
  destinationNormalized: string;
  purpose: string;
  code: string;
  createdAt: Date;
  expiresAt: Date;
};

/**
 * Process-local fixture inbox — plaintext codes never touch PostgreSQL.
 * Dev/test only.
 */
@Injectable()
export class FixtureInbox {
  private readonly messages: FixtureInboxEntry[] = [];

  push(entry: Omit<FixtureInboxEntry, 'id' | 'createdAt'>): FixtureInboxEntry {
    const full: FixtureInboxEntry = {
      ...entry,
      id: randomUUID(),
      createdAt: new Date(),
    };
    this.messages.push(full);
    return full;
  }

  /** One-time retrieval; expired entries are dropped. */
  consume(destination: string, purpose: string): FixtureInboxEntry | null {
    const now = Date.now();
    for (let i = 0; i < this.messages.length; i += 1) {
      const message = this.messages[i];
      if (message.expiresAt.getTime() <= now) {
        this.messages.splice(i, 1);
        i -= 1;
        continue;
      }
      if (
        message.destinationNormalized === destination &&
        message.purpose === purpose
      ) {
        this.messages.splice(i, 1);
        return message;
      }
    }
    return null;
  }

  clear(): void {
    this.messages.length = 0;
  }

  /** Test helper — never expose in production controllers. */
  snapshot(): readonly FixtureInboxEntry[] {
    return [...this.messages];
  }
}

@Injectable()
export class FixtureSmsDelivery implements SmsDeliveryPort {
  constructor(private readonly inbox: FixtureInbox) {}

  async sendOtp(input: {
    destinationE164: string;
    purpose: string;
    code: string;
    expiresAt: Date;
  }): Promise<void> {
    await Promise.resolve();
    this.inbox.push({
      channel: 'SMS',
      destinationNormalized: input.destinationE164,
      purpose: input.purpose,
      code: input.code,
      expiresAt: input.expiresAt,
    });
  }
}

@Injectable()
export class FixtureEmailDelivery implements EmailDeliveryPort {
  constructor(private readonly inbox: FixtureInbox) {}

  async sendCode(input: {
    destinationEmail: string;
    purpose: string;
    code: string;
    expiresAt: Date;
  }): Promise<void> {
    await Promise.resolve();
    this.inbox.push({
      channel: 'EMAIL',
      destinationNormalized: input.destinationEmail,
      purpose: input.purpose,
      code: input.code,
      expiresAt: input.expiresAt,
    });
  }
}

/** Staging/prod placeholder — fail closed until a real adapter is wired. */
@Injectable()
export class UnavailableSmsDelivery implements SmsDeliveryPort {
  async sendOtp(): Promise<void> {
    await Promise.resolve();
    throw new AppError('DELIVERY_UNAVAILABLE', 503);
  }
}

@Injectable()
export class UnavailableEmailDelivery implements EmailDeliveryPort {
  async sendCode(): Promise<void> {
    await Promise.resolve();
    throw new AppError('DELIVERY_UNAVAILABLE', 503);
  }
}

import { HttpStatus, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { SanitizedExceptionFilter } from '../src/common/errors/app-error';
import { PrismaService } from '../src/database/prisma.service';
import { normalizePhone } from '../src/common/security/crypto.util';

type ChallengeResponse = {
  challengeId: string;
  maskedDestination: string;
};

type TokenResponse = {
  accessToken: string;
  refreshToken: string;
  accountId: string;
};

type FixtureResponse = {
  code?: string;
};

type SessionListItem = {
  sessionId: string;
  isCurrent: boolean;
  revoked: boolean;
};

describe('Auth e2e (phone-only)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  const fixtureKey = process.env.FIXTURE_INBOX_KEY ?? '';

  beforeAll(async () => {
    process.env.APP_ENVIRONMENT = process.env.APP_ENVIRONMENT ?? 'test';
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleRef.createNestApplication();
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new SanitizedExceptionFilter());
    await app.init();
    prisma = app.get(PrismaService);
    await prisma.refreshToken.deleteMany();
    await prisma.authSession.deleteMany();
    await prisma.authChallenge.deleteMany();
    await prisma.rateLimitBucket.deleteMany();
    await prisma.securityEvent.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await app.close();
  });

  async function readCode(
    destination: string,
    purpose: string,
  ): Promise<string> {
    const res = await request(app.getHttpServer())
      .get('/v1/dev/fixtures/inbox')
      .query({ destination, purpose })
      .set('X-Fixture-Key', fixtureKey)
      .expect(HttpStatus.OK);
    const body = res.body as FixtureResponse;
    expect(body.code).toBeTruthy();
    return body.code as string;
  }

  async function signInPhone(phone: string): Promise<TokenResponse> {
    const normalized = normalizePhone(phone);
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(normalized, 'PHONE_SIGN_IN');
    const verifiedRes = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
    return verifiedRes.body as TokenResponse;
  }

  it('phone challenge → verify → token pair with accountId only', async () => {
    const tokens = await signInPhone('09121110001');
    expect(tokens.accessToken).toBeTruthy();
    expect(tokens.refreshToken).toBeTruthy();
    expect(tokens.accountId).toBeTruthy();
    expect(tokens).not.toHaveProperty('hasPhone');
    expect(tokens).not.toHaveProperty('hasEmail');
    expect(tokens).not.toHaveProperty('maskedPhone');
    expect(tokens).not.toHaveProperty('maskedEmail');
  });

  it('repeat phone login returns the same accountId', async () => {
    const first = await signInPhone('09121110002');
    const second = await signInPhone('09121110002');
    expect(second.accountId).toBe(first.accountId);
  });

  it('refresh rotates and reuse revokes the family', async () => {
    const tokens = await signInPhone('09121110003');
    const refreshed = await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: tokens.refreshToken })
      .expect(HttpStatus.OK);
    const next = refreshed.body as TokenResponse;
    expect(next.refreshToken).not.toBe(tokens.refreshToken);

    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: tokens.refreshToken })
      .expect(HttpStatus.UNAUTHORIZED);

    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: next.refreshToken })
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('protected /account/me and sessions/logout work', async () => {
    const tokens = await signInPhone('09121110004');
    const me = await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${tokens.accessToken}`)
      .expect(HttpStatus.OK);
    expect(me.body).toEqual({ accountId: tokens.accountId });

    const sessions = await request(app.getHttpServer())
      .get('/v1/auth/sessions')
      .set('Authorization', `Bearer ${tokens.accessToken}`)
      .expect(HttpStatus.OK);
    const list = sessions.body as SessionListItem[];
    expect(list.some((s) => s.isCurrent)).toBe(true);

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${tokens.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${tokens.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('logout-all revokes every session', async () => {
    const a = await signInPhone('09121110005');
    const b = await signInPhone('09121110005');
    await request(app.getHttpServer())
      .post('/v1/auth/logout-all')
      .set('Authorization', `Bearer ${b.accessToken}`)
      .expect(HttpStatus.OK);
    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${b.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('invalid OTP is rejected', async () => {
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone: '09121110006' })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code: '000000' })
      .expect(HttpStatus.BAD_REQUEST);
  });

  it('rejects consumed and expired OTP challenges', async () => {
    const phone = '09121110007';
    const normalized = normalizePhone(phone);
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(normalized, 'PHONE_SIGN_IN');

    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.BAD_REQUEST);

    const expiredPhone = '09121110008';
    const expiredNormalized = normalizePhone(expiredPhone);
    const expiredChallengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone: expiredPhone })
      .expect(HttpStatus.OK);
    const expiredChallenge = expiredChallengeRes.body as ChallengeResponse;
    const expiredCode = await readCode(expiredNormalized, 'PHONE_SIGN_IN');
    await prisma.authChallenge.update({
      where: { id: expiredChallenge.challengeId },
      data: { expiresAt: new Date(Date.now() - 60_000) },
    });
    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${expiredChallenge.challengeId}/verify`)
      .send({ code: expiredCode })
      .expect(HttpStatus.BAD_REQUEST);
  });

  it('concurrent phone verification allows only one success', async () => {
    const phone = '09121110009';
    const normalized = normalizePhone(phone);
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(normalized, 'PHONE_SIGN_IN');

    const results = await Promise.all([
      request(app.getHttpServer())
        .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
        .send({ code }),
      request(app.getHttpServer())
        .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
        .send({ code }),
    ]);

    const statuses = results.map((r) => r.status).sort((a, b) => a - b);
    expect(statuses).toEqual([200, 400]);
    const success = results.find((r) => r.status === 200);
    expect((success?.body as TokenResponse).accountId).toBeTruthy();
  });

  it('revokes a non-current session by id', async () => {
    const first = await signInPhone('09121110010');
    const second = await signInPhone('09121110010');
    const sessionsRes = await request(app.getHttpServer())
      .get('/v1/auth/sessions')
      .set('Authorization', `Bearer ${second.accessToken}`)
      .expect(HttpStatus.OK);
    const sessions = sessionsRes.body as SessionListItem[];
    const other = sessions.find((s) => !s.isCurrent && !s.revoked);
    expect(other).toBeDefined();

    await request(app.getHttpServer())
      .delete(`/v1/auth/sessions/${other!.sessionId}`)
      .set('Authorization', `Bearer ${second.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${first.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${second.accessToken}`)
      .expect(HttpStatus.OK);
  });

  it('deprecated email/password endpoints are absent', async () => {
    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-up')
      .send({ email: 'x@example.com', password: 'correct-horse-battery' })
      .expect(HttpStatus.NOT_FOUND);
    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email: 'x@example.com', password: 'correct-horse-battery' })
      .expect(HttpStatus.NOT_FOUND);
    await request(app.getHttpServer())
      .post('/v1/auth/password/reset-challenges')
      .send({ email: 'x@example.com' })
      .expect(HttpStatus.NOT_FOUND);
    await request(app.getHttpServer())
      .put('/v1/account/password')
      .send({
        currentPassword: 'correct-horse-battery',
        newPassword: 'correct-horse-battery-2',
      })
      .expect(HttpStatus.NOT_FOUND);
    await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .send({ email: 'x@example.com', password: 'correct-horse-battery' })
      .expect(HttpStatus.NOT_FOUND);
    await request(app.getHttpServer())
      .delete('/v1/account/phone')
      .expect(HttpStatus.NOT_FOUND);
  });
});

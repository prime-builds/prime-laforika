import { HttpStatus, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { SanitizedExceptionFilter } from '../src/common/errors/app-error';
import { PrismaService } from '../src/database/prisma.service';
import { hashPassword } from '../src/common/security/crypto.util';

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

describe('Auth e2e', () => {
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

  async function signUpEmail(
    email: string,
    password: string,
  ): Promise<TokenResponse> {
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-up')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(email, 'EMAIL_VERIFY');
    const verifiedRes = await request(app.getHttpServer())
      .post('/v1/auth/email/verify')
      .send({ challengeId: challenge.challengeId, code })
      .expect(HttpStatus.OK);
    return verifiedRes.body as TokenResponse;
  }

  async function signInPhone(phone: string): Promise<TokenResponse> {
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(phone, 'PHONE_SIGN_IN');
    const verifiedRes = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
    return verifiedRes.body as TokenResponse;
  }

  it('phone signup, attach email, login email same account', async () => {
    const phone = '+989121111111';
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challengeBody = challengeRes.body as ChallengeResponse;

    const code = await readCode(phone, 'PHONE_SIGN_IN');
    const verifiedRes = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challengeBody.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
    const verified = verifiedRes.body as TokenResponse;
    expect(verified.accountId).toBeTruthy();

    const attachRes = await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({
        email: 'user1@example.com',
        password: 'correct-horse-battery-1',
      })
      .expect(HttpStatus.OK);
    const attach = attachRes.body as ChallengeResponse;

    const emailCode = await readCode('user1@example.com', 'EMAIL_ATTACH');
    await request(app.getHttpServer())
      .post('/v1/account/email/verify')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({ challengeId: attach.challengeId, code: emailCode })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);

    const loginRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({
        email: 'user1@example.com',
        password: 'correct-horse-battery-1',
      })
      .expect(HttpStatus.OK);
    const login = loginRes.body as TokenResponse;
    expect(login.accountId).toBe(verified.accountId);
  });

  it('refresh rotation replay revokes family', async () => {
    const phone = '+989122222222';
    const createdRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const created = createdRes.body as ChallengeResponse;
    const code = await readCode(phone, 'PHONE_SIGN_IN');
    const verifiedRes = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${created.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
    const verified = verifiedRes.body as TokenResponse;
    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: verified.refreshToken })
      .expect(HttpStatus.OK);
    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: verified.refreshToken })
      .expect(HttpStatus.UNAUTHORIZED);

    const events = await prisma.securityEvent.findMany({
      where: { type: 'REFRESH_REPLAY', accountId: verified.accountId },
    });
    expect(events.length).toBeGreaterThanOrEqual(1);
    const sessions = await prisma.authSession.findMany({
      where: { userId: verified.accountId },
    });
    expect(sessions.every((s) => s.revokedAt !== null)).toBe(true);
  });

  it('email signup cannot login before verification', async () => {
    const email = 'pending-before-verify@example.com';
    const password = 'correct-horse-battery-pv';
    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-up')
      .send({ email, password })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.UNAUTHORIZED);

    const user = await prisma.user.findUnique({
      where: { emailNormalized: email },
    });
    expect(user).toBeNull();
  });

  it('email attachment stays inactive until verification', async () => {
    const phone = '+989129999001';
    const verified = await signInPhone(phone);
    const email = 'attach-pending@example.com';
    const password = 'correct-horse-battery-ap';

    await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({ email, password })
      .expect(HttpStatus.OK);

    const meRes = await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);
    expect(meRes.body).toMatchObject({ hasEmail: false });

    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.UNAUTHORIZED);

    const user = await prisma.user.findUniqueOrThrow({
      where: { id: verified.accountId },
    });
    expect(user.emailNormalized).toBeNull();
    expect(user.passwordHash).toBeNull();
  });

  it('five failed challenge attempts persist and block correct code', async () => {
    const phone = '+989129999002';
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(phone, 'PHONE_SIGN_IN');

    for (let i = 0; i < 5; i += 1) {
      await request(app.getHttpServer())
        .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
        .send({ code: '000000' })
        .expect(HttpStatus.BAD_REQUEST);
    }

    const stored = await prisma.authChallenge.findUniqueOrThrow({
      where: { id: challenge.challengeId },
    });
    expect(stored.attempts).toBe(5);

    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.BAD_REQUEST);
  });

  it('concurrent refresh yields at most one success and revokes losers', async () => {
    const phone = '+989129999003';
    const verified = await signInPhone(phone);
    const results = await Promise.all(
      Array.from({ length: 8 }, () =>
        request(app.getHttpServer())
          .post('/v1/auth/refresh')
          .send({ refreshToken: verified.refreshToken }),
      ),
    );
    const successes = results.filter((r) => r.status === 200);
    const failures = results.filter((r) => r.status === 401);
    expect(successes.length).toBe(1);
    expect(failures.length).toBe(7);

    // Losing concurrent requests revoke the family after the winner claims.
    const winner = successes[0]?.body as TokenResponse;
    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: verified.refreshToken })
      .expect(HttpStatus.UNAUTHORIZED);
    await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: winner.refreshToken })
      .expect(HttpStatus.UNAUTHORIZED);

    const events = await prisma.securityEvent.findMany({
      where: { type: 'REFRESH_REPLAY', accountId: verified.accountId },
    });
    expect(events.length).toBeGreaterThanOrEqual(1);
  });

  it('fixture inbox is one-time and rejects wrong key; no DB plaintext codes', async () => {
    const phone = '+989129999004';
    await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/dev/fixtures/inbox')
      .query({ destination: phone, purpose: 'PHONE_SIGN_IN' })
      .set('X-Fixture-Key', 'wrong-key')
      .expect(HttpStatus.FORBIDDEN);

    const first = await readCode(phone, 'PHONE_SIGN_IN');
    expect(first).toMatch(/^\d{6}$/);

    const second = await request(app.getHttpServer())
      .get('/v1/dev/fixtures/inbox')
      .query({ destination: phone, purpose: 'PHONE_SIGN_IN' })
      .set('X-Fixture-Key', fixtureKey)
      .expect(HttpStatus.OK);
    expect(second.body).toEqual({});

    const tables = await prisma.$queryRaw<Array<{ tablename: string }>>`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public' AND tablename = 'fixture_inbox_messages'
    `;
    expect(tables).toHaveLength(0);
  });

  it('email signup, verify, then email login', async () => {
    const email = 'user3@example.com';
    const password = 'correct-horse-battery-3';
    const verified = await signUpEmail(email, password);

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);

    const loginRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const login = loginRes.body as TokenResponse;
    expect(login.accountId).toBe(verified.accountId);
  });

  it('email-created user attaches phone then phone login same account', async () => {
    const email = 'user4@example.com';
    const password = 'correct-horse-battery-4';
    const phone = '+989124444444';
    const verified = await signUpEmail(email, password);

    const attachRes = await request(app.getHttpServer())
      .post('/v1/account/phone/challenges')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({ phone })
      .expect(HttpStatus.OK);
    const attach = attachRes.body as ChallengeResponse;

    const phoneCode = await readCode(phone, 'PHONE_ATTACH');
    await request(app.getHttpServer())
      .post(`/v1/account/phone/challenges/${attach.challengeId}/verify`)
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({ code: phoneCode })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);

    const phoneLogin = await signInPhone(phone);
    expect(phoneLogin.accountId).toBe(verified.accountId);
  });

  it('duplicate credential attachment is rejected without merge', async () => {
    const ownerPhone = '+989125555551';
    const ownerEmail = 'user5-owner@example.com';
    const ownerPassword = 'correct-horse-battery-5';
    const attackerEmail = 'user5-attacker@example.com';
    const attackerPassword = 'correct-horse-battery-5a';

    const owner = await signInPhone(ownerPhone);
    const attachEmailRes = await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .set('Authorization', `Bearer ${owner.accessToken}`)
      .send({ email: ownerEmail, password: ownerPassword })
      .expect(HttpStatus.OK);
    const attachEmail = attachEmailRes.body as ChallengeResponse;
    const emailCode = await readCode(ownerEmail, 'EMAIL_ATTACH');
    await request(app.getHttpServer())
      .post('/v1/account/email/verify')
      .set('Authorization', `Bearer ${owner.accessToken}`)
      .send({ challengeId: attachEmail.challengeId, code: emailCode })
      .expect(HttpStatus.OK);

    const attacker = await signUpEmail(attackerEmail, attackerPassword);

    const conflictPhone = await request(app.getHttpServer())
      .post('/v1/account/phone/challenges')
      .set('Authorization', `Bearer ${attacker.accessToken}`)
      .send({ phone: ownerPhone })
      .expect(HttpStatus.CONFLICT);
    expect(conflictPhone.body).toMatchObject({ code: 'AUTH_CONFLICT' });

    const conflictEmail = await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .set('Authorization', `Bearer ${attacker.accessToken}`)
      .send({ email: ownerEmail, password: 'correct-horse-battery-5b' })
      .expect(HttpStatus.CONFLICT);
    expect(conflictEmail.body).toMatchObject({ code: 'AUTH_CONFLICT' });

    const meRes = await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${attacker.accessToken}`)
      .expect(HttpStatus.OK);
    expect(meRes.body).toMatchObject({
      accountId: attacker.accountId,
    });
    expect(meRes.body).not.toMatchObject({ accountId: owner.accountId });
  });

  it('password reset works and revokes prior sessions', async () => {
    const email = 'user6@example.com';
    const oldPassword = 'correct-horse-battery-6';
    const newPassword = 'correct-horse-battery-6n';
    const verified = await signUpEmail(email, oldPassword);

    const resetChallengeRes = await request(app.getHttpServer())
      .post('/v1/auth/password/reset-challenges')
      .send({ email })
      .expect(HttpStatus.OK);
    const resetChallenge = resetChallengeRes.body as ChallengeResponse;
    const resetCode = await readCode(email, 'PASSWORD_RESET');

    await request(app.getHttpServer())
      .post('/v1/auth/password/reset')
      .send({
        challengeId: resetChallenge.challengeId,
        code: resetCode,
        newPassword,
      })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);

    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password: oldPassword })
      .expect(HttpStatus.UNAUTHORIZED);

    const loginRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password: newPassword })
      .expect(HttpStatus.OK);
    const login = loginRes.body as TokenResponse;
    expect(login.accountId).toBe(verified.accountId);
  });

  it('revoked session cannot access /account/me with unexpired access token', async () => {
    const phone = '+989127777777';
    const verified = await signInPhone(phone);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('logout, individual session revoke, and logout-all', async () => {
    const email = 'user8@example.com';
    const password = 'correct-horse-battery-8';
    const signup = await signUpEmail(email, password);
    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${signup.accessToken}`)
      .expect(HttpStatus.OK);

    const sessionARes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const sessionA = sessionARes.body as TokenResponse;

    const sessionBRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const sessionB = sessionBRes.body as TokenResponse;

    const listRes = await request(app.getHttpServer())
      .get('/v1/auth/sessions')
      .set('Authorization', `Bearer ${sessionB.accessToken}`)
      .expect(HttpStatus.OK);
    const sessions = listRes.body as SessionListItem[];
    const activeOther = sessions.filter((s) => !s.isCurrent && !s.revoked);
    expect(activeOther).toHaveLength(1);
    const sessionAId = activeOther[0]?.sessionId;
    expect(sessionAId).toBeTruthy();

    await request(app.getHttpServer())
      .delete(`/v1/auth/sessions/${sessionAId}`)
      .set('Authorization', `Bearer ${sessionB.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${sessionA.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${sessionB.accessToken}`)
      .expect(HttpStatus.OK);

    const sessionCRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const sessionC = sessionCRes.body as TokenResponse;

    await request(app.getHttpServer())
      .post('/v1/auth/logout-all')
      .set('Authorization', `Bearer ${sessionC.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${sessionB.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${sessionC.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);

    const sessionDRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.OK);
    const sessionD = sessionDRes.body as TokenResponse;

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${sessionD.accessToken}`)
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${sessionD.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('email login returns generic failure for wrong password', async () => {
    const email = 'user9@example.com';
    const password = 'correct-horse-battery-9';
    await signUpEmail(email, password);

    const failed = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password: 'wrong-password-xxxx' })
      .expect(HttpStatus.UNAUTHORIZED);
    expect(failed.body).toMatchObject({
      code: 'AUTH_INVALID_CREDENTIALS',
      message: 'Request failed',
    });
  });

  it('password change revokes sessions and requires new password', async () => {
    const email = 'user10@example.com';
    const oldPassword = 'correct-horse-battery-10';
    const newPassword = 'correct-horse-battery-10n';
    const verified = await signUpEmail(email, oldPassword);

    await request(app.getHttpServer())
      .put('/v1/account/password')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .send({ currentPassword: oldPassword, newPassword })
      .expect(HttpStatus.OK);

    await request(app.getHttpServer())
      .get('/v1/account/me')
      .set('Authorization', `Bearer ${verified.accessToken}`)
      .expect(HttpStatus.UNAUTHORIZED);

    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password: oldPassword })
      .expect(HttpStatus.UNAUTHORIZED);

    const loginRes = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password: newPassword })
      .expect(HttpStatus.OK);
    const login = loginRes.body as TokenResponse;
    expect(login.accountId).toBe(verified.accountId);
  });

  it('legacy unverified email/password row cannot authenticate', async () => {
    const email = 'legacy-unverified@example.com';
    const password = 'correct-horse-battery-legacy';
    const passwordHash = await hashPassword(
      password,
      process.env.PASSWORD_PEPPER as string,
    );
    await prisma.user.create({
      data: {
        emailNormalized: email,
        emailDisplay: email,
        passwordHash,
        emailVerifiedAt: null,
      },
    });

    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({ email, password })
      .expect(HttpStatus.UNAUTHORIZED);

    const stored = await prisma.user.findUniqueOrThrow({
      where: { emailNormalized: email },
    });
    expect(stored.emailVerifiedAt).toBeNull();
  });

  it('concurrent phone verification allows exactly one success', async () => {
    const phone = '+989129999010';
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(phone, 'PHONE_SIGN_IN');

    const results = await Promise.all(
      Array.from({ length: 6 }, () =>
        request(app.getHttpServer())
          .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
          .send({ code }),
      ),
    );
    const successes = results.filter((r) => r.status === 200);
    const failures = results.filter((r) => r.status !== 200);
    expect(successes.length).toBe(1);
    expect(failures.length).toBe(5);

    const stored = await prisma.authChallenge.findUniqueOrThrow({
      where: { id: challenge.challengeId },
    });
    expect(stored.consumedAt).not.toBeNull();
    const users = await prisma.user.findMany({ where: { phoneE164: phone } });
    expect(users).toHaveLength(1);
  });

  it('wrong purpose does not consume a valid challenge', async () => {
    const phone = '+989129999011';
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challenge = challengeRes.body as ChallengeResponse;
    const code = await readCode(phone, 'PHONE_SIGN_IN');

    await request(app.getHttpServer())
      .post('/v1/auth/email/verify')
      .send({ challengeId: challenge.challengeId, code })
      .expect(HttpStatus.BAD_REQUEST);

    const stored = await prisma.authChallenge.findUniqueOrThrow({
      where: { id: challenge.challengeId },
    });
    expect(stored.consumedAt).toBeNull();

    await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challenge.challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
  });

  it('rate-limit bucket keys never store raw email or phone', async () => {
    const phone = '+989129999012';
    const email = 'rate-limit-privacy@example.com';
    await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    await request(app.getHttpServer())
      .post('/v1/auth/email/sign-up')
      .send({ email, password: 'correct-horse-battery-rl' })
      .expect(HttpStatus.OK);

    const buckets = await prisma.rateLimitBucket.findMany();
    for (const bucket of buckets) {
      expect(bucket.bucketKey).not.toContain(phone);
      expect(bucket.bucketKey).not.toContain(email);
      expect(bucket.bucketKey).not.toContain('example.com');
      expect(bucket.bucketKey).not.toMatch(/\+989/);
    }
    expect(
      buckets.some((b) => b.bucketKey.startsWith('challenge:dest:v1:')),
    ).toBe(true);
  });
});

import { HttpStatus, INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { SanitizedExceptionFilter } from '../src/common/errors/app-error';
import { PrismaService } from '../src/database/prisma.service';
import { normalizePhone } from '../src/common/security/crypto.util';

type TokenResponse = {
  accessToken: string;
  refreshToken: string;
  accountId: string;
};

type ProfileResponse = {
  accountId: string;
  phone: string;
  phoneVerified: boolean;
  firstName: string | null;
  lastName: string | null;
  email: string | null;
  emailVerified: boolean;
};

type FixtureResponse = { code?: string };

describe('Profile e2e', () => {
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
  });

  beforeEach(async () => {
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
    return (res.body as FixtureResponse).code as string;
  }

  async function signInPhone(phone: string): Promise<TokenResponse> {
    const normalized = normalizePhone(phone);
    const challengeRes = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(HttpStatus.OK);
    const challengeId = (challengeRes.body as { challengeId: string })
      .challengeId;
    const code = await readCode(normalized, 'PHONE_SIGN_IN');
    const tokenRes = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challengeId}/verify`)
      .send({ code })
      .expect(HttpStatus.OK);
    return tokenRes.body as TokenResponse;
  }

  it('rejects unauthorized GET/PATCH', async () => {
    await request(app.getHttpServer())
      .get('/v1/account/profile')
      .expect(HttpStatus.UNAUTHORIZED);
    await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .send({ firstName: 'Ali' })
      .expect(HttpStatus.UNAUTHORIZED);
  });

  it('GET/PATCH profile for current account only', async () => {
    const a = await signInPhone('09123330001');
    const b = await signInPhone('09123330002');

    const getA = await request(app.getHttpServer())
      .get('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .expect(HttpStatus.OK);
    const profileA = getA.body as ProfileResponse;
    expect(profileA.accountId).toBe(a.accountId);
    expect(profileA.phone).toBe(normalizePhone('09123330001'));
    expect(profileA.phoneVerified).toBe(true);
    expect(profileA.firstName).toBeNull();

    const patched = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({
        firstName: '  علی  ',
        lastName: 'محمدی',
        email: 'Contact.A@Example.com',
      })
      .expect(HttpStatus.OK);
    const body = patched.body as ProfileResponse;
    expect(body.firstName).toBe('علی');
    expect(body.lastName).toBe('محمدی');
    expect(body.email).toBe('Contact.A@Example.com');
    expect(body.emailVerified).toBe(false);
    expect(body.phone).toBe(normalizePhone('09123330001'));

    const getB = await request(app.getHttpServer())
      .get('/v1/account/profile')
      .set('Authorization', `Bearer ${b.accessToken}`)
      .expect(HttpStatus.OK);
    expect((getB.body as ProfileResponse).firstName).toBeNull();
    expect((getB.body as ProfileResponse).accountId).toBe(b.accountId);
  });

  it('rejects duplicate contact email and clears/preserves verification', async () => {
    const a = await signInPhone('09123330003');
    const b = await signInPhone('09123330004');

    await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: 'shared@example.com' })
      .expect(HttpStatus.OK);

    await prisma.user.update({
      where: { id: a.accountId },
      data: { emailVerifiedAt: new Date() },
    });

    const preserved = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: '  shared@example.com  ' })
      .expect(HttpStatus.OK);
    expect((preserved.body as ProfileResponse).emailVerified).toBe(true);

    const conflict = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${b.accessToken}`)
      .send({ email: 'Shared@Example.com' })
      .expect(HttpStatus.CONFLICT);
    expect((conflict.body as { code: string }).code).toBe(
      'PROFILE_EMAIL_IN_USE',
    );

    const cleared = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: null })
      .expect(HttpStatus.OK);
    expect((cleared.body as ProfileResponse).email).toBeNull();
    expect((cleared.body as ProfileResponse).emailVerified).toBe(false);
  });

  it('rejects overlong names and unknown fields; phone cannot be patched', async () => {
    const a = await signInPhone('09123330005');
    await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ firstName: 'ن'.repeat(101) })
      .expect(HttpStatus.BAD_REQUEST);

    await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ phone: '+989121111111' })
      .expect(HttpStatus.BAD_REQUEST);

    const blank = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ firstName: '  ', lastName: null })
      .expect(HttpStatus.OK);
    expect((blank.body as ProfileResponse).firstName).toBeNull();
    expect((blank.body as ProfileResponse).lastName).toBeNull();
  });

  it('serializes concurrent same-account email updates without divergence', async () => {
    const a = await signInPhone('09123330006');

    await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: 'Verified.User@Example.com' })
      .expect(HttpStatus.OK);

    await prisma.user.update({
      where: { id: a.accountId },
      data: { emailVerifiedAt: new Date('2026-03-01T00:00:00.000Z') },
    });

    const [changeRes, displayRes] = await Promise.all([
      request(app.getHttpServer())
        .patch('/v1/account/profile')
        .set('Authorization', `Bearer ${a.accessToken}`)
        .send({ email: 'Changed.User@Example.com' }),
      request(app.getHttpServer())
        .patch('/v1/account/profile')
        .set('Authorization', `Bearer ${a.accessToken}`)
        .send({ email: '  verified.user@example.com  ' }),
    ]);

    expect(changeRes.status).toBe(HttpStatus.OK);
    expect(displayRes.status).toBe(HttpStatus.OK);

    const stored = await prisma.user.findUniqueOrThrow({
      where: { id: a.accountId },
    });

    // Display and normalized cannot diverge after concurrent writes.
    expect(stored.emailNormalized).not.toBeNull();
    expect(stored.emailDisplay).not.toBeNull();
    expect(stored.emailNormalized).toBe(
      stored.emailDisplay!.trim().toLowerCase(),
    );
    expect(['changed.user@example.com', 'verified.user@example.com']).toContain(
      stored.emailNormalized,
    );

    // An actual email change always clears verification.
    if (stored.emailNormalized === 'changed.user@example.com') {
      expect(stored.emailDisplay).toBe('Changed.User@Example.com');
      expect(stored.emailVerifiedAt).toBeNull();
    }

    // Re-seed verified email, then prove display-only preserve vs change clear.
    await prisma.user.update({
      where: { id: a.accountId },
      data: {
        emailNormalized: 'stable.user@example.com',
        emailDisplay: 'Stable.User@Example.com',
        emailVerifiedAt: new Date('2026-03-02T00:00:00.000Z'),
      },
    });

    const preserved = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: '  stable.user@example.com  ' })
      .expect(HttpStatus.OK);
    expect((preserved.body as ProfileResponse).email).toBe(
      'stable.user@example.com',
    );
    expect((preserved.body as ProfileResponse).emailVerified).toBe(true);

    const changed = await request(app.getHttpServer())
      .patch('/v1/account/profile')
      .set('Authorization', `Bearer ${a.accessToken}`)
      .send({ email: 'Other.User@Example.com' })
      .expect(HttpStatus.OK);
    expect((changed.body as ProfileResponse).email).toBe(
      'Other.User@Example.com',
    );
    expect((changed.body as ProfileResponse).emailVerified).toBe(false);
  });
});

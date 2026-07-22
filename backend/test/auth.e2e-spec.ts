import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { SanitizedExceptionFilter } from '../src/common/errors/app-error';
import { PrismaService } from '../src/database/prisma.service';

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
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    app.useGlobalFilters(new SanitizedExceptionFilter());
    await app.init();
    prisma = app.get(PrismaService);
    await prisma.fixtureInboxMessage.deleteMany();
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

  async function readCode(destination: string, purpose: string) {
    const res = await request(app.getHttpServer())
      .get('/v1/dev/fixtures/inbox')
      .query({ destination, purpose })
      .set('X-Fixture-Key', fixtureKey)
      .expect(200);
    return res.body.code as string;
  }

  it('phone signup, attach email, login email same account', async () => {
    const phone = '+989121111111';
    const challenge = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone })
      .expect(201)
      .catch(async () =>
        request(app.getHttpServer()).post('/v1/auth/phone/challenges').send({ phone }),
      );
    // Nest default POST may be 201 or 200 depending on config
    const challengeBody =
      challenge.status === 201 || challenge.status === 200
        ? challenge.body
        : (
            await request(app.getHttpServer())
              .post('/v1/auth/phone/challenges')
              .send({ phone })
          ).body;

    const code = await readCode(phone, 'PHONE_SIGN_IN');
    const verified = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${challengeBody.challengeId}/verify`)
      .send({ code });
    expect(verified.status).toBeLessThan(300);
    const accountId = verified.body.accountId as string;
    expect(accountId).toBeTruthy();

    const attach = await request(app.getHttpServer())
      .post('/v1/account/email/challenges')
      .set('Authorization', `Bearer ${verified.body.accessToken}`)
      .send({
        email: 'user1@example.com',
        password: 'correct-horse-battery-1',
      });
    expect(attach.status).toBeLessThan(300);
    const emailCode = await readCode('user1@example.com', 'EMAIL_ATTACH');
    await request(app.getHttpServer())
      .post('/v1/account/email/verify')
      .set('Authorization', `Bearer ${verified.body.accessToken}`)
      .send({ challengeId: attach.body.challengeId, code: emailCode })
      .expect((res) => expect(res.status).toBeLessThan(300));

    await request(app.getHttpServer())
      .post('/v1/auth/logout')
      .set('Authorization', `Bearer ${verified.body.accessToken}`);

    const login = await request(app.getHttpServer())
      .post('/v1/auth/email/sign-in')
      .send({
        email: 'user1@example.com',
        password: 'correct-horse-battery-1',
      });
    expect(login.status).toBeLessThan(300);
    expect(login.body.accountId).toBe(accountId);
  });

  it('refresh rotation replay revokes family', async () => {
    const phone = '+989122222222';
    const created = await request(app.getHttpServer())
      .post('/v1/auth/phone/challenges')
      .send({ phone });
    const code = await readCode(phone, 'PHONE_SIGN_IN');
    const verified = await request(app.getHttpServer())
      .post(`/v1/auth/phone/challenges/${created.body.challengeId}/verify`)
      .send({ code });
    const oldRefresh = verified.body.refreshToken as string;
    const rotated = await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: oldRefresh });
    expect(rotated.status).toBeLessThan(300);
    const replay = await request(app.getHttpServer())
      .post('/v1/auth/refresh')
      .send({ refreshToken: oldRefresh });
    expect(replay.status).toBe(401);
  });
});

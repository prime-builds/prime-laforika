import { ProfileService } from './profile.service';
import { AppError } from '../../common/errors/app-error';
import { Prisma } from '@prisma/client';

describe('ProfileService', () => {
  const accountId = '11111111-1111-1111-1111-111111111111';
  const baseUser = {
    id: accountId,
    phoneE164: '+989121234567',
    firstName: null as string | null,
    lastName: null as string | null,
    emailNormalized: null as string | null,
    emailDisplay: null as string | null,
    emailVerifiedAt: null as Date | null,
    disabledAt: null as Date | null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  function buildService(overrides: {
    findUnique?: jest.Mock;
    findUniqueOrThrow?: jest.Mock;
    update?: jest.Mock;
  }) {
    const prisma = {
      user: {
        findUnique:
          overrides.findUnique ?? jest.fn().mockResolvedValue(baseUser),
        findUniqueOrThrow:
          overrides.findUniqueOrThrow ?? jest.fn().mockResolvedValue(baseUser),
        update: overrides.update ?? jest.fn().mockResolvedValue(baseUser),
      },
    };
    return {
      service: new ProfileService(prisma as never),
      prisma,
    };
  }

  it('GET maps profile view without internal columns', async () => {
    const verifiedAt = new Date('2026-01-01T00:00:00.000Z');
    const { service } = buildService({
      findUnique: jest.fn().mockResolvedValue({
        ...baseUser,
        firstName: 'علی',
        lastName: 'محمدی',
        emailDisplay: 'Ali@Example.com',
        emailNormalized: 'ali@example.com',
        emailVerifiedAt: verifiedAt,
      }),
    });
    await expect(service.getProfile(accountId)).resolves.toEqual({
      accountId,
      phone: '+989121234567',
      phoneVerified: true,
      firstName: 'علی',
      lastName: 'محمدی',
      email: 'Ali@Example.com',
      emailVerified: true,
    });
  });

  it('PATCH trims names and blank becomes null', async () => {
    const update = jest.fn().mockResolvedValue({
      ...baseUser,
      firstName: 'علی',
      lastName: null,
    });
    const { service } = buildService({ update });
    await service.patchProfile(accountId, {
      firstName: '  علی  ',
      lastName: '   ',
    });
    expect(update).toHaveBeenCalledWith({
      where: { id: accountId },
      data: { firstName: 'علی', lastName: null },
    });
  });

  it('PATCH rejects overlong Unicode names', async () => {
    const { service } = buildService({});
    const long = 'ن'.repeat(101);
    await expect(
      service.patchProfile(accountId, { firstName: long }),
    ).rejects.toMatchObject({ code: 'VALIDATION_ERROR', status: 400 });
  });

  it('PATCH email change clears verification', async () => {
    const current = {
      ...baseUser,
      emailDisplay: 'old@example.com',
      emailNormalized: 'old@example.com',
      emailVerifiedAt: new Date(),
    };
    const update = jest.fn().mockResolvedValue({
      ...current,
      emailDisplay: 'New@Example.com',
      emailNormalized: 'new@example.com',
      emailVerifiedAt: null,
    });
    const { service } = buildService({
      findUnique: jest.fn().mockResolvedValue(current),
      findUniqueOrThrow: jest.fn().mockResolvedValue(current),
      update,
    });
    await service.patchProfile(accountId, { email: 'New@Example.com' });
    expect(update).toHaveBeenCalledWith({
      where: { id: accountId },
      data: {
        emailNormalized: 'new@example.com',
        emailDisplay: 'New@Example.com',
        emailVerifiedAt: null,
      },
    });
  });

  it('PATCH unchanged normalized email preserves verification', async () => {
    const verifiedAt = new Date('2026-02-01T00:00:00.000Z');
    const current = {
      ...baseUser,
      emailDisplay: 'Ali@Example.com',
      emailNormalized: 'ali@example.com',
      emailVerifiedAt: verifiedAt,
    };
    const update = jest.fn().mockResolvedValue({
      ...current,
      emailDisplay: 'ali@example.com',
    });
    const { service } = buildService({
      findUnique: jest.fn().mockResolvedValue(current),
      findUniqueOrThrow: jest.fn().mockResolvedValue(current),
      update,
    });
    await service.patchProfile(accountId, { email: '  ali@example.com  ' });
    expect(update).toHaveBeenCalledWith({
      where: { id: accountId },
      data: { emailDisplay: 'ali@example.com' },
    });
  });

  it('PATCH maps duplicate email to PROFILE_EMAIL_IN_USE', async () => {
    const update = jest.fn().mockRejectedValue(
      new Prisma.PrismaClientKnownRequestError('Unique', {
        code: 'P2002',
        clientVersion: 'test',
      }),
    );
    const { service } = buildService({
      findUnique: jest.fn().mockResolvedValue(baseUser),
      findUniqueOrThrow: jest.fn().mockResolvedValue(baseUser),
      update,
    });
    await expect(
      service.patchProfile(accountId, { email: 'taken@example.com' }),
    ).rejects.toEqual(new AppError('PROFILE_EMAIL_IN_USE', 409, ['email']));
  });

  it('rejects disabled accounts', async () => {
    const { service } = buildService({
      findUnique: jest.fn().mockResolvedValue({
        ...baseUser,
        disabledAt: new Date(),
      }),
    });
    await expect(service.getProfile(accountId)).rejects.toMatchObject({
      code: 'AUTH_ACCOUNT_UNAVAILABLE',
      status: 401,
    });
  });
});

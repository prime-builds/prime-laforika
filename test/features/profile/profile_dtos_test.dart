import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';

void main() {
  test('ProfileDto round-trips JSON including null names/email', () {
    final dto = ProfileDto.fromJson({
      'accountId': 'acc-1',
      'phone': '+989121234567',
      'phoneVerified': true,
      'firstName': null,
      'lastName': null,
      'email': null,
      'emailVerified': false,
    });
    expect(dto.accountId, 'acc-1');
    expect(dto.phone, '+989121234567');
    expect(dto.phoneVerified, isTrue);
    expect(dto.firstName, isNull);
    expect(dto.email, isNull);
    expect(dto.emailVerified, isFalse);
    expect(dto.toJson()['phone'], '+989121234567');
  });

  test('PatchProfileRequest omit vs null semantics', () {
    expect(const PatchProfileRequest().toJson(), isEmpty);
    expect(
      const PatchProfileRequest(
        firstName: null,
        includeFirstName: true,
      ).toJson(),
      {'firstName': null},
    );
    expect(
      const PatchProfileRequest(
        email: 'a@b.co',
        includeEmail: true,
        includeFirstName: true,
        firstName: 'Ali',
      ).toJson(),
      {'firstName': 'Ali', 'email': 'a@b.co'},
    );
  });
}

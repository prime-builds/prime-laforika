import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/features/profile/presentation/profile_validation.dart';

void main() {
  test('normalization trims and turns blank fields into null', () {
    expect(normalizeProfileName('  علی  '), 'علی');
    expect(normalizeProfileName('   '), isNull);
    expect(normalizeProfileEmail('  A@Example.com  '), 'A@Example.com');
    expect(normalizeProfileEmail(''), isNull);
  });

  test('validation mirrors server limits and conservative email syntax', () {
    expect(
      isValidProfileDraft(
        firstName: List.filled(100, 'ن').join(),
        lastName: '',
        email: 'contact@example.com',
      ),
      isTrue,
    );
    expect(
      isValidProfileDraft(
        firstName: List.filled(101, 'ن').join(),
        lastName: '',
        email: '',
      ),
      isFalse,
    );
    expect(
      isValidProfileDraft(firstName: '', lastName: '', email: 'invalid'),
      isFalse,
    );
    expect(
      isValidProfileDraft(
        firstName: '',
        lastName: '',
        email: 'a..b@example.com',
      ),
      isFalse,
    );
  });
}

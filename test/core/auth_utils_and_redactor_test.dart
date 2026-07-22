import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/network/http_redactor.dart';
import 'package:laforika/core/utils/auth_utils.dart';

void main() {
  group('HttpRedactor', () {
    test('redacts sensitive headers and body fields', () {
      final headers = HttpRedactor.redactHeaders({
        'Authorization': 'Bearer secret',
        'Content-Type': 'application/json',
      });
      expect(headers['Authorization'], '***');
      expect(headers['Content-Type'], 'application/json');

      final body =
          HttpRedactor.redact({
                'email': 'a@b.com',
                'password': 'super-secret-password',
                'code': '123456',
                'ok': true,
              })
              as Map;
      expect(body['email'], '***');
      expect(body['password'], '***');
      expect(body['code'], '***');
      expect(body['ok'], true);
    });
  });

  group('toLatinDigits', () {
    test('converts Persian and Arabic digits', () {
      expect(toLatinDigits('۰۹۱۲'), '0912');
      expect(toLatinDigits('٠٩١٢'), '0912');
      expect(toLatinDigits('0912'), '0912');
    });
  });

  group('isValidReturnDestination', () {
    test('accepts registered internal paths and rejects loops/external', () {
      final registered = {'/', '/account/security'};
      final authOnly = {'/auth', '/auth/phone'};
      expect(
        isValidReturnDestination(
          '/account/security',
          registeredPaths: registered,
          authOnlyPaths: authOnly,
          startupPath: '/startup',
        ),
        isTrue,
      );
      expect(
        isValidReturnDestination(
          '/auth',
          registeredPaths: registered,
          authOnlyPaths: authOnly,
          startupPath: '/startup',
        ),
        isFalse,
      );
      expect(
        isValidReturnDestination(
          'https://evil.example',
          registeredPaths: registered,
          authOnlyPaths: authOnly,
          startupPath: '/startup',
        ),
        isFalse,
      );
      expect(
        isValidReturnDestination(
          '/startup',
          registeredPaths: registered,
          authOnlyPaths: authOnly,
          startupPath: '/startup',
        ),
        isFalse,
      );
    });
  });

  group('Result', () {
    test('exposes success and failure helpers', () {
      const ok = Success<int>(1);
      const bad = FailureResult<int>(NetworkFailure());
      expect(ok.isSuccess, isTrue);
      expect(bad.isFailure, isTrue);
      expect(ok.valueOrNull, 1);
      expect(bad.failureOrNull, isA<NetworkFailure>());
    });
  });
}

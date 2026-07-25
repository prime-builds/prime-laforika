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
        'X-Fixture-Key': 'fixture-secret',
      });
      expect(headers['Authorization'], '***');
      expect(headers['Content-Type'], 'application/json');
      expect(headers['X-Fixture-Key'], '***');

      final body =
          HttpRedactor.redact({
                'email': 'a@b.com',
                'password': 'super-secret-password',
                'code': '123456',
                'destination': '+989121234567',
                'purpose': 'PHONE_SIGN_IN',
                'challengeId': 'chal-1',
                'nested': {'otp': '999999', 'ok': true},
                'ok': true,
              })
              as Map;
      expect(body['email'], '***');
      expect(body['password'], '***');
      expect(body['code'], '***');
      expect(body['destination'], '***');
      expect(body['purpose'], '***');
      expect(body['challengeId'], '***');
      expect((body['nested'] as Map)['otp'], '***');
      expect((body['nested'] as Map)['ok'], true);
      expect(body['ok'], true);
    });

    test('redacts sensitive query parameter values', () {
      final query = HttpRedactor.redactQueryParameters({
        'destination': 'a@b.com',
        'purpose': 'EMAIL_ATTACH',
        'page': '1',
      });
      expect(query['destination'], '***');
      expect(query['purpose'], '***');
      expect(query['page'], '1');
    });

    test('redactUri and safeRequestPath strip query and fragment', () {
      final uri = Uri.parse(
        'https://api.example/v1/dev/fixtures/inbox'
        '?destination=a@b.com&purpose=PHONE_SIGN_IN#x',
      );
      expect(HttpRedactor.redactUri(uri), '/v1/dev/fixtures/inbox');
    });
  });

  group('toLatinDigits', () {
    test('converts Persian and Arabic digits', () {
      expect(toLatinDigits('۰۹۱۲'), '0912');
      expect(toLatinDigits('٠٩١٢'), '0912');
      expect(toLatinDigits('0912'), '0912');
    });
  });

  group('canonicalizeReturnDestination (path-only policy)', () {
    const registered = {'/', '/account/security'};
    const authOnly = {'/auth'};
    const startup = '/startup';

    String? canon(String? value) => canonicalizeReturnDestination(
      value,
      registeredPaths: registered,
      authOnlyPaths: authOnly,
      startupPath: startup,
    );

    test('returns canonical registered public and protected paths', () {
      expect(canon('/'), '/');
      expect(canon('/account/security'), '/account/security');
      expect(
        isValidReturnDestination(
          '/account/security',
          registeredPaths: registered,
          authOnlyPaths: authOnly,
          startupPath: startup,
        ),
        isTrue,
      );
    });

    test('rejects auth-only and startup paths', () {
      expect(canon('/auth'), isNull);
      expect(canon('/startup'), isNull);
    });

    test('rejects query parameters and fragments', () {
      expect(canon('/account/security?x=1'), isNull);
      expect(canon('/account/security?from=/'), isNull);
      expect(canon('/account/security#section'), isNull);
      expect(canon('/?q=1'), isNull);
      expect(canon('/#top'), isNull);
    });

    test('rejects external schemes and protocol-relative authorities', () {
      expect(canon('https://evil.example/path'), isNull);
      expect(canon('http://evil.example'), isNull);
      expect(canon('//evil.example/path'), isNull);
    });

    test('rejects unknown, malformed, and empty values', () {
      expect(canon(null), isNull);
      expect(canon(''), isNull);
      expect(canon('/unknown/module'), isNull);
      expect(canon('not a path'), isNull);
      expect(canon('account/security'), isNull);
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

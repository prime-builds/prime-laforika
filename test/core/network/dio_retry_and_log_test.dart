import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/core/network/http_redactor.dart';

class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this._handler);

  final Future<ResponseBody> Function(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  )
  _handler;

  int fetchCount = 0;
  final List<RequestOptions> seen = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCount += 1;
    seen.add(options);
    return _handler(options, requestStream, cancelFuture);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IdempotentRetryInterceptor', () {
    test(
      'retries GET on shared Dio adapter without constructing bare Dio',
      () async {
        var attempts = 0;
        final adapter = _CountingAdapter((options, _, _) async {
          attempts += 1;
          if (attempts == 1) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            );
          }
          return ResponseBody.fromString(
            '{"ok":true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final dio = Dio(
          BaseOptions(
            baseUrl: 'http://shared.example/v1',
            headers: const {'X-Shared': 'yes'},
          ),
        );
        dio.httpClientAdapter = adapter;

        final retry = IdempotentRetryInterceptor();
        dio.interceptors.add(retry);
        retry.attach(dio);

        final response = await dio.get<Map<String, dynamic>>(
          '/health',
          queryParameters: const {'destination': 'secret@example.com'},
        );

        expect(response.statusCode, 200);
        expect(adapter.fetchCount, 2);
        expect(attempts, 2);
        expect(
          adapter.seen.every((o) => o.baseUrl == 'http://shared.example/v1'),
          isTrue,
        );
        expect(
          adapter.seen.every((o) => o.headers['X-Shared'] == 'yes'),
          isTrue,
        );
        expect(adapter.seen.last.extra['retryCount'], 1);
      },
    );

    test('does not retry POST', () async {
      final adapter = _CountingAdapter((options, _, _) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://shared.example/v1'));
      dio.httpClientAdapter = adapter;
      final retry = IdempotentRetryInterceptor();
      dio.interceptors.add(retry);
      retry.attach(dio);

      await expectLater(
        () => dio.post<void>('/auth/phone/challenges'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.fetchCount, 1);
    });
  });

  group('SanitizedLogInterceptor', () {
    test('logs method and path only — never raw query', () async {
      final prints = <String>[];
      final previous = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) prints.add(message);
      };
      addTearDown(() => debugPrint = previous);

      final adapter = _CountingAdapter((options, _, _) async {
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://example.test/v1'));
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(SanitizedLogInterceptor());

      await dio.get<Map<String, dynamic>>(
        '/dev/fixtures/inbox',
        queryParameters: const {
          'destination': '+989121234567',
          'purpose': 'PHONE_SIGN_IN',
        },
        options: Options(
          headers: {'X-Fixture-Key': 'super-secret-fixture-key'},
        ),
      );

      expect(prints, isNotEmpty);
      final joined = prints.join('\n');
      expect(joined, contains('GET /v1/dev/fixtures/inbox'));
      expect(joined, isNot(contains('destination=')));
      expect(joined, isNot(contains('+989121234567')));
      expect(joined, isNot(contains('PHONE_SIGN_IN')));
      expect(joined, isNot(contains('super-secret-fixture-key')));
      expect(joined, contains('***'));
    });
  });

  group('HttpRedactor path helpers', () {
    test('redactUri strips query and fragment', () {
      final uri = Uri.parse(
        'http://host/v1/dev/fixtures/inbox'
        '?destination=a@b.com&purpose=EMAIL_ATTACH#frag',
      );
      expect(HttpRedactor.redactUri(uri), '/v1/dev/fixtures/inbox');
    });

    test('safeRequestPath ignores query on RequestOptions', () {
      final options = RequestOptions(
        path: '/dev/fixtures/inbox',
        baseUrl: 'http://host/v1',
        queryParameters: const {
          'destination': 'a@b.com',
          'purpose': 'EMAIL_ATTACH',
        },
      );
      expect(HttpRedactor.safeRequestPath(options), '/v1/dev/fixtures/inbox');
    });
  });
}

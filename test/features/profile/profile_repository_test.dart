import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';
import 'package:laforika/features/profile/data/profile_repository.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  RequestOptions? last;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return _handler(options);
  }
}

void main() {
  test('GET profile maps success body', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test/v1'));
    dio.httpClientAdapter = _Adapter(
      (_) async => ResponseBody.fromString(
        jsonEncode({
          'accountId': 'acc-1',
          'phone': '+989121234567',
          'phoneVerified': true,
          'firstName': 'علی',
          'lastName': null,
          'email': 'A@Example.com',
          'emailVerified': false,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );

    final result = await ProfileRepository(dio).getProfile();
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.firstName, 'علی');
    expect(result.valueOrNull?.email, 'A@Example.com');
  });

  test('PATCH sends only included fields and maps conflict', () async {
    late final _Adapter adapter;
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test/v1'));
    adapter = _Adapter((options) async {
      expect(options.method, 'PATCH');
      expect(options.path, '/account/profile');
      expect(options.data, {'email': 'taken@example.com'});
      return ResponseBody.fromString(
        jsonEncode({'code': 'PROFILE_EMAIL_IN_USE', 'message': 'conflict'}),
        409,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    dio.httpClientAdapter = adapter;

    final result = await ProfileRepository(dio).patchProfile(
      const PatchProfileRequest(email: 'taken@example.com', includeEmail: true),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
    expect(result.failureOrNull?.code, 'PROFILE_EMAIL_IN_USE');
  });

  test('GET maps transport failure', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test/v1'));
    dio.httpClientAdapter = _Adapter((options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });

    final result = await ProfileRepository(dio).getProfile();
    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}

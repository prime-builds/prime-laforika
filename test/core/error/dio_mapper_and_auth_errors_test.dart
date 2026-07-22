import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/error/dio_exception_mapper.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/storage/flutter_secure_store.dart';
import 'package:laforika/features/auth/presentation/auth_error_mapper.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

void main() {
  group('mapDioException', () {
    test('maps timeouts and connection errors', () {
      expect(
        mapDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isA<TimeoutFailure>(),
      );
      expect(
        mapDioException(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        isA<NetworkFailure>(),
      );
    });

    test('maps auth, validation, and server responses', () {
      final auth = mapDioException(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 401,
            data: const {'code': 'AUTH_INVALID_CREDENTIALS'},
          ),
        ),
      );
      expect(auth, isA<AuthFailure>());
      expect(auth.code, 'AUTH_INVALID_CREDENTIALS');

      final validation = mapDioException(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 400,
            data: const {'code': 'AUTH_LAST_CREDENTIAL'},
          ),
        ),
      );
      expect(validation, isA<ValidationFailure>());
      expect(validation.code, 'AUTH_LAST_CREDENTIAL');

      final server = mapDioException(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 500,
            data: const {'code': 'SERVER_ERROR'},
          ),
        ),
      );
      expect(server, isA<ServerFailure>());
    });
  });

  group('scopedSecureStorageKey', () {
    test('partitions by environment wire name', () {
      expect(
        scopedSecureStorageKey(AppEnvironment.dev, 'auth.refreshToken'),
        'dev:auth.refreshToken',
      );
      expect(
        scopedSecureStorageKey(AppEnvironment.prod, 'auth.refreshToken'),
        'prod:auth.refreshToken',
      );
    });
  });

  group('mapAuthFailure', () {
    test('maps known codes to localized Persian messages', () async {
      final l10n = await AppLocalizations.delegate.load(
        const Locale('fa', 'IR'),
      );
      expect(
        mapAuthFailure(
          l10n,
          const AuthFailure(code: 'AUTH_INVALID_CREDENTIALS'),
        ),
        l10n.authErrorInvalidCredentials,
      );
      expect(
        mapAuthFailure(
          l10n,
          const ValidationFailure(code: 'AUTH_LAST_CREDENTIAL'),
        ),
        l10n.authErrorLastCredential,
      );
      expect(
        mapAuthFailure(l10n, const NetworkFailure()),
        l10n.authErrorNetwork,
      );
      expect(
        mapAuthFailure(l10n, const UnknownFailure()),
        l10n.authErrorGeneric,
      );
    });
  });
}

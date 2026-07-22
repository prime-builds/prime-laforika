import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/network/http_redactor.dart';

/// Extra flag: skip attaching Authorization and skip 401 refresh.
const String kSkipAuthExtra = 'skipAuth';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(IdempotentRetryInterceptor());
  if (kDebugMode && config.logLevel == AppLogLevel.debug) {
    dio.interceptors.add(SanitizedLogInterceptor());
  }

  return dio;
});

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skip = options.extra[kSkipAuthExtra] == true;
    if (!skip) {
      final token = _ref.read(authSessionGatewayProvider).accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final request = err.requestOptions;
    final skip = request.extra[kSkipAuthExtra] == true;
    final alreadyRetried = request.extra['authRetried'] == true;

    if (skip ||
        response?.statusCode != 401 ||
        alreadyRetried ||
        request.path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    final gateway = _ref.read(authSessionGatewayProvider);
    final refreshResult = await gateway.refreshAccessToken();

    switch (refreshResult) {
      case Success(:final value):
        request.headers['Authorization'] = 'Bearer $value';
        request.extra['authRetried'] = true;
        try {
          final dio = _ref.read(dioProvider);
          final response = await dio.fetch<dynamic>(request);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      case FailureResult(:final failure):
        if (failure is AuthFailure) {
          await _ref
              .read(authControllerProvider.notifier)
              .forceUnauthenticated();
        }
        return handler.next(err);
    }
  }
}

class IdempotentRetryInterceptor extends Interceptor {
  static const _maxRetries = 2;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();
    final isIdempotent = method == 'GET' || method == 'HEAD';
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    final isTransient =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!isIdempotent || !isTransient || retryCount >= _maxRetries) {
      return handler.next(err);
    }

    err.requestOptions.extra['retryCount'] = retryCount + 1;
    await Future<void>.delayed(Duration(milliseconds: 200 * (retryCount + 1)));
    try {
      final response = await Dio().fetch<dynamic>(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

class SanitizedLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '[dio] → ${options.method} ${options.uri} '
      'headers=${HttpRedactor.redactHeaders(Map<String, dynamic>.from(options.headers))} '
      'data=${HttpRedactor.redact(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[dio] ← ${response.statusCode} ${response.requestOptions.uri} '
      'data=${HttpRedactor.redact(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '[dio] ✕ ${err.type} ${err.requestOptions.uri} '
      'status=${err.response?.statusCode}',
    );
    handler.next(err);
  }
}

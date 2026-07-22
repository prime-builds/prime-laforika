import 'package:dio/dio.dart';

import 'package:laforika/core/error/failure.dart';

/// Maps Dio/transport exceptions to sealed [Failure] values.
Failure mapDioException(Object error) {
  if (error is! DioException) {
    return UnknownFailure(message: error.runtimeType.toString());
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutFailure();
    case DioExceptionType.connectionError:
    case DioExceptionType.unknown:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _mapResponse(error.response);
    case DioExceptionType.cancel:
      return const NetworkFailure(code: 'REQUEST_CANCELLED');
    case DioExceptionType.badCertificate:
      return const NetworkFailure(code: 'BAD_CERTIFICATE');
  }
}

Failure _mapResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final data = response?.data;
  String code = 'SERVER_ERROR';
  String? message;

  if (data is Map) {
    final rawCode = data['code'];
    if (rawCode is String && rawCode.isNotEmpty) {
      code = rawCode;
    }
    final rawMessage = data['message'];
    if (rawMessage is String && rawMessage.isNotEmpty) {
      message = rawMessage;
    }
  }

  if (status == 401 || status == 403) {
    return AuthFailure(code: code, message: message);
  }
  if (status == 404) {
    return NotFoundFailure(code: code, message: message);
  }
  if (status == 400 || status == 422) {
    return ValidationFailure(code: code, message: message);
  }
  return ServerFailure(code: code, message: message, statusCode: status);
}

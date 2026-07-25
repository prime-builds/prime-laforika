import 'package:dio/dio.dart';

import 'package:laforika/core/error/dio_exception_mapper.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/core/utils/auth_utils.dart';
import 'package:laforika/features/auth/data/auth_dtos.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Options get _skipAuth => Options(extra: const {kSkipAuthExtra: true});

  Future<Result<ChallengeCreatedDto>> requestPhoneChallenge({
    required String phone,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/phone/challenges',
        data: {'phone': toLatinDigits(phone)},
        options: _skipAuth,
      );
      return ChallengeCreatedDto.fromJson(response.data!);
    });
  }

  Future<Result<TokenPairDto>> verifyPhoneChallenge({
    required String challengeId,
    required String code,
  }) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/phone/challenges/$challengeId/verify',
        data: {'code': toLatinDigits(code)},
        options: _skipAuth,
      );
      return TokenPairDto.fromJson(response.data!);
    });
  }

  Future<Result<TokenPairDto>> refresh({required String refreshToken}) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: _skipAuth,
      );
      return TokenPairDto.fromJson(response.data!);
    });
  }

  Future<Result<AccountMeDto>> me() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>('/account/me');
      return AccountMeDto.fromJson(response.data!);
    });
  }

  Future<Result<List<SessionDto>>> listSessions() {
    return _guard(() async {
      final response = await _dio.get<List<dynamic>>('/auth/sessions');
      return response.data!
          .cast<Map<String, dynamic>>()
          .map(SessionDto.fromJson)
          .toList(growable: false);
    });
  }

  Future<Result<void>> revokeSession(String sessionId) {
    return _guard(() async {
      await _dio.delete<void>('/auth/sessions/$sessionId');
    });
  }

  Future<Result<void>> logout() {
    return _guard(() async {
      await _dio.post<void>('/auth/logout');
    });
  }

  Future<Result<void>> logoutAll() {
    return _guard(() async {
      await _dio.post<void>('/auth/logout-all');
    });
  }

  Future<Result<FixtureMessageDto?>> readFixtureInbox({
    required String fixtureKey,
    required String destination,
    required String purpose,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/dev/fixtures/inbox',
        queryParameters: {'destination': destination, 'purpose': purpose},
        options: Options(
          extra: const {kSkipAuthExtra: true},
          headers: {'X-Fixture-Key': fixtureKey},
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty || data['code'] == null) {
        return null;
      }
      return FixtureMessageDto.fromJson(data);
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on Object catch (error) {
      return FailureResult(mapDioException(error));
    }
  }
}

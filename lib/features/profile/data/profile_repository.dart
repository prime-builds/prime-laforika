import 'package:dio/dio.dart';

import 'package:laforika/core/error/dio_exception_mapper.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<Result<ProfileDto>> getProfile() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>('/account/profile');
      return ProfileDto.fromJson(response.data!);
    });
  }

  Future<Result<ProfileDto>> patchProfile(PatchProfileRequest request) {
    return _guard(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/account/profile',
        data: request.toJson(),
      );
      return ProfileDto.fromJson(response.data!);
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

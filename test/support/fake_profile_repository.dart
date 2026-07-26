import 'package:laforika/core/error/failure.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';
import 'package:laforika/features/profile/data/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  Result<ProfileDto> getResult = const FailureResult(
    NetworkFailure(message: 'unset'),
  );
  Result<ProfileDto> patchResult = const FailureResult(
    NetworkFailure(message: 'unset'),
  );
  PatchProfileRequest? lastPatch;
  int getCalls = 0;
  int patchCalls = 0;
  Duration patchDelay = Duration.zero;

  @override
  Future<Result<ProfileDto>> getProfile() async {
    getCalls += 1;
    return getResult;
  }

  @override
  Future<Result<ProfileDto>> patchProfile(PatchProfileRequest request) async {
    patchCalls += 1;
    lastPatch = request;
    if (patchDelay > Duration.zero) {
      await Future<void>.delayed(patchDelay);
    }
    return patchResult;
  }
}

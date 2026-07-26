import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/auth/auth_state.dart';
import 'package:laforika/core/error/failure.dart';
import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/features/profile/data/profile_dtos.dart';
import 'package:laforika/features/profile/data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

/// Account-scoped profile load/save. Auto-disposes; rebuilds on auth change.
class ProfileController extends AsyncNotifier<ProfileDto?> {
  @override
  Future<ProfileDto?> build() async {
    final auth = ref.watch(authControllerProvider);
    if (auth is! AuthAuthenticated) {
      return null;
    }
    // Depend on accountId so a different principal forces a fresh fetch.
    final _ = auth.principal.accountId;
    final result = await ref.read(profileRepositoryProvider).getProfile();
    return result.when(
      success: (value) => value,
      failure: (failure) =>
          Error.throwWithStackTrace(failure, StackTrace.current),
    );
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// Persists editable fields. On failure, editor retains draft input.
  ///
  /// Stale successes after logout, account change, or disposal are ignored.
  Future<Result<ProfileDto>> save(PatchProfileRequest request) async {
    final auth = ref.read(authControllerProvider);
    if (auth is! AuthAuthenticated) {
      return const FailureResult(AuthFailure(code: 'AUTH_REQUIRED'));
    }
    final initiatingAccountId = auth.principal.accountId;

    final result = await ref
        .read(profileRepositoryProvider)
        .patchProfile(request);

    if (!ref.mounted) {
      return result;
    }

    final currentAuth = ref.read(authControllerProvider);
    final stillSameAccount =
        currentAuth is AuthAuthenticated &&
        currentAuth.principal.accountId == initiatingAccountId;

    if (result case Success(:final value)) {
      if (stillSameAccount && value.accountId == initiatingAccountId) {
        state = AsyncData(value);
      }
    }
    return result;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, ProfileDto?>(
      ProfileController.new,
    );

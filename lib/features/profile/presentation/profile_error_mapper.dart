import 'package:laforika/core/error/failure.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

String mapProfileFailure(AppLocalizations l10n, Failure failure) {
  return switch (failure.code) {
    'PROFILE_EMAIL_IN_USE' => l10n.profileErrorEmailInUse,
    'VALIDATION_ERROR' => l10n.profileErrorValidation,
    'NETWORK_ERROR' => l10n.profileErrorNetwork,
    'TIMEOUT' => l10n.profileErrorNetwork,
    'AUTH_SESSION_REVOKED' => l10n.authErrorSessionRevoked,
    _ => l10n.profileErrorGeneric,
  };
}

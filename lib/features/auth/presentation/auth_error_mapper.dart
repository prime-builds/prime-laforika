import 'package:laforika/core/error/failure.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

String mapAuthFailure(AppLocalizations l10n, Failure failure) {
  return switch (failure.code) {
    'AUTH_INVALID_CREDENTIALS' => l10n.authErrorInvalidCredentials,
    'AUTH_CHALLENGE_EXPIRED' => l10n.authErrorChallengeExpired,
    'AUTH_CHALLENGE_INVALID' => l10n.authErrorChallengeInvalid,
    'AUTH_RATE_LIMITED' => l10n.authErrorRateLimited,
    'AUTH_CONFLICT' => l10n.authErrorConflict,
    'AUTH_SESSION_REVOKED' => l10n.authErrorSessionRevoked,
    'AUTH_LAST_CREDENTIAL' => l10n.authErrorLastCredential,
    'VALIDATION_ERROR' => l10n.authErrorValidation,
    'NETWORK_ERROR' => l10n.authErrorNetwork,
    'TIMEOUT' => l10n.authErrorNetwork,
    _ => l10n.authErrorGeneric,
  };
}

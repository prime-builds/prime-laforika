/// Sealed failure hierarchy mapped at repository boundaries.
sealed class Failure {
  const Failure({required this.code, this.message});

  /// Stable machine-readable code (backend or local).
  final String code;

  /// Optional non-user-facing diagnostic note (never raw secrets/PII).
  final String? message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.code = 'NETWORK_ERROR', super.message});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.code = 'TIMEOUT', super.message});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.code, super.message, this.statusCode});

  final int? statusCode;
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.code, super.message});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.code = 'NOT_FOUND', super.message});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.code = 'VALIDATION_ERROR',
    super.message,
    this.fields = const {},
  });

  final Map<String, List<String>> fields;
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.code = 'UNKNOWN', super.message});
}

/// Repository boundary result — plain sealed Success/FailureResult (no dartz).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    FailureResult() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success() => null,
    FailureResult(:final failure) => failure,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      FailureResult(failure: final f) => failure(f),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}

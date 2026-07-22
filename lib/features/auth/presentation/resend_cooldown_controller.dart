import 'dart:async';

import 'package:flutter/foundation.dart';

/// Drives UI rebuilds while a server-authored resend cooldown is active.
///
/// [resendAvailableAt] is authoritative. A 1s [Timer] notifies [onChanged]
/// until the cooldown elapses; callers must cancel via [dispose].
class ResendCooldownController {
  ResendCooldownController({
    required this.onChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final VoidCallback onChanged;
  final DateTime Function() _clock;

  Timer? _timer;
  DateTime? _resendAvailableAt;

  DateTime? get resendAvailableAt => _resendAvailableAt;

  bool get canResend {
    final at = _resendAvailableAt;
    return at == null || !_clock().isBefore(at);
  }

  int get remainingSeconds {
    final at = _resendAvailableAt;
    if (at == null) return 0;
    final seconds = at.difference(_clock()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  void update(DateTime? resendAvailableAt) {
    _resendAvailableAt = resendAvailableAt;
    _syncTimer();
    onChanged();
  }

  void clear() {
    update(null);
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (canResend) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (canResend) {
        _timer?.cancel();
        _timer = null;
      }
      onChanged();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

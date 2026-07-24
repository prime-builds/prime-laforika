import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/app/app.dart';
import 'package:laforika/app/config/env.dart';
import 'package:laforika/app/fatal_startup_app.dart';
import 'package:laforika/core/auth/auth_controller.dart';
import 'package:laforika/core/config/app_config.dart';
import 'package:laforika/core/config/app_config_provider.dart';
import 'package:laforika/core/network/dio_provider.dart';
import 'package:laforika/core/storage/secure_store_provider.dart';
import 'package:laforika/features/auth/auth.dart';

/// Application bootstrap: binding, config, error zone, and ProviderScope.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      // Binding and runApp must share the same zone (required on web).
      WidgetsFlutterBinding.ensureInitialized();

      late final AppConfig config;
      try {
        config = Env.load();
      } on FormatException {
        _reportSanitizedDiagnostic(
          'Configuration validation failed at startup.',
        );
        runApp(const FatalStartupApp());
        return;
      } on Object {
        _reportSanitizedDiagnostic(
          'Unexpected configuration failure at startup.',
        );
        runApp(const FatalStartupApp());
        return;
      }

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _reportSanitizedDiagnostic('A Flutter framework error occurred.');
      };

      runApp(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            authSessionGatewayProvider.overrideWith((ref) {
              // Use read (not watch) so the gateway instance stays stable for the
              // process lifetime. Watching dio/secureStore would recreate the
              // gateway and drop the in-memory access token after login.
              return CustomApiAuthGateway(
                repository: AuthRepository(ref.read(dioProvider)),
                secureStore: ref.read(secureStoreProvider),
              );
            }),
          ],
          child: const LaforikaApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      _reportSanitizedDiagnostic('An unexpected uncaught error occurred.');
    },
  );
}

void _reportSanitizedDiagnostic(String message) {
  // Until O4, emit only sanitized local diagnostics — never raw exceptions,
  // config values, credentials, or personal data.
  if (kDebugMode) {
    developer.log(message, name: 'laforika');
  }
}

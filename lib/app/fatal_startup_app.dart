import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/core/theme/app_tokens.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Deterministic localized fatal surface for configuration/startup failures.
///
/// Never displays raw exceptions or implementation details.
/// Theme follows system brightness without depending on preference storage.
class FatalStartupApp extends StatelessWidget {
  const FatalStartupApp({super.key});

  static const Locale _locale = Locale('fa', 'IR');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      locale: _locale,
      supportedLocales: const <Locale>[_locale],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _FatalStartupScreen(),
    );
  }
}

class _FatalStartupScreen extends StatelessWidget {
  const _FatalStartupScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.center,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppTokens.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.fatalStartupTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.spaceMd),
                Text(
                  l10n.fatalStartupMessage,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

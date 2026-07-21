import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laforika/app/router/app_router.dart';
import 'package:laforika/core/theme/app_theme.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

/// Root application widget: theme, Persian locale, and router.
class LaforikaApp extends ConsumerWidget {
  const LaforikaApp({super.key});

  static const Locale locale = Locale('fa', 'IR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Laforika',
      theme: buildAppTheme(),
      locale: locale,
      supportedLocales: const <Locale>[locale],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

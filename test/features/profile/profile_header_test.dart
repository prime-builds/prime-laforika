import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/features/profile/presentation/profile_header.dart';
import 'package:laforika/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('RTL places Settings right and Notifications left', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    var settingsTaps = 0;
    var notificationsTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ProfileHeader(
              title: l10n.profileTitle,
              settingsTooltip: l10n.profileSettingsTooltip,
              notificationsTooltip: l10n.profileNotificationsTooltip,
              onSettings: () => settingsTaps += 1,
              onNotifications: () => notificationsTaps += 1,
            ),
          ),
        ),
      ),
    );

    final settingsX = tester
        .getCenter(find.byKey(const Key('profile_header_settings')))
        .dx;
    final notificationsX = tester
        .getCenter(find.byKey(const Key('profile_header_notifications')))
        .dx;
    expect(settingsX, greaterThan(notificationsX));

    await tester.tap(find.byKey(const Key('profile_header_settings')));
    await tester.tap(find.byKey(const Key('profile_header_notifications')));
    expect(settingsTaps, 1);
    expect(notificationsTaps, 1);
  });

  testWidgets('production header omits dead Settings/Notifications', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('fa', 'IR'));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ProfileHeader(title: l10n.profileTitle)),
      ),
    );
    expect(find.byKey(const Key('profile_header_settings')), findsNothing);
    expect(find.byKey(const Key('profile_header_notifications')), findsNothing);
  });
}

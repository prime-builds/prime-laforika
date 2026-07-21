// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'لفوریکا';

  @override
  String get homeWelcomeMessage => 'لفوریکا آماده است';

  @override
  String get fatalStartupTitle => 'راه‌اندازی ناموفق';

  @override
  String get fatalStartupMessage =>
      'پیکربندی برنامه معتبر نیست. لطفاً دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.';
}

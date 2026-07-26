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
  String get homeWelcomeTitle => 'به لفوریکا خوش آمدید';

  @override
  String get homeWelcomeSubtitle =>
      'از اینجا به بخش‌های در دسترس لفوریکا دسترسی دارید.';

  @override
  String get homeAvailableSectionsTitle => 'دسترسی سریع';

  @override
  String get homeAccountSecurityTitle => 'امنیت حساب';

  @override
  String get homeAccountSecurityDescription =>
      'نشست‌های فعال را مدیریت کنید و از حساب خارج شوید.';

  @override
  String get homeOpenAccountSecurity => 'باز کردن امنیت حساب';

  @override
  String get homeLogoutTooltip => 'خروج از حساب';

  @override
  String get shellHomeLabel => 'خانه';

  @override
  String get shellProfileLabel => 'پروفایل';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get profileGuestIntro =>
      'برای مدیریت پروفایل با شماره موبایل وارد شوید.';

  @override
  String get profileAvatarSemantic => 'تصویر نمایه';

  @override
  String get profileFirstNameLabel => 'نام';

  @override
  String get profileLastNameLabel => 'نام خانوادگی';

  @override
  String get profilePhoneLabel => 'شماره موبایل تأییدشده';

  @override
  String get profilePhoneVerified => 'تأییدشده';

  @override
  String get profileEmailLabel => 'ایمیل تماس (اختیاری)';

  @override
  String get profileEmailVerified => 'ایمیل تأیید شده است';

  @override
  String get profileEmailUnverified => 'ایمیل تماس تأیید نشده است';

  @override
  String get profileSave => 'ذخیره';

  @override
  String get profileSaving => 'در حال ذخیره…';

  @override
  String get profileSaved => 'پروفایل ذخیره شد.';

  @override
  String get profileRetry => 'تلاش دوباره';

  @override
  String get profileErrorEmailInUse => 'این ایمیل برای حساب دیگری ثبت شده است.';

  @override
  String get profileErrorValidation => 'اطلاعات پروفایل معتبر نیست.';

  @override
  String get profileErrorNetwork =>
      'ارتباط برقرار نشد. اتصال اینترنت را بررسی کنید.';

  @override
  String get profileErrorGeneric =>
      'ذخیره پروفایل ممکن نشد. لطفاً دوباره تلاش کنید.';

  @override
  String get profileSettingsTooltip => 'تنظیمات';

  @override
  String get profileNotificationsTooltip => 'اعلان‌ها';

  @override
  String get shellSearchLabel => 'جستجو';

  @override
  String get shellSearchHint => 'جستجو در بخش‌های خانه';

  @override
  String get shellSearchClear => 'پاک کردن جستجو';

  @override
  String get shellSearchNoResults => 'موردی یافت نشد.';

  @override
  String get fatalStartupTitle => 'راه‌اندازی ناموفق';

  @override
  String get fatalStartupMessage =>
      'پیکربندی برنامه معتبر نیست. لطفاً دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.';

  @override
  String get authStartupLoading => 'در حال بازیابی نشست…';

  @override
  String get authStartupError =>
      'بازیابی نشست ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get authRetry => 'تلاش دوباره';

  @override
  String get authPhoneTitle => 'ورود با موبایل';

  @override
  String get authPhoneLabel => 'شماره موبایل';

  @override
  String get authOtpLabel => 'کد تأیید';

  @override
  String get authSendCode => 'ارسال کد';

  @override
  String get authVerifyCode => 'تأیید کد';

  @override
  String get authResendCode => 'ارسال مجدد کد';

  @override
  String authResendInSeconds(int seconds) {
    return 'ارسال مجدد تا $seconds ثانیه';
  }

  @override
  String get authPleaseWait => 'لطفاً صبر کنید…';

  @override
  String authCodeSentTo(String destination) {
    return 'کد به $destination ارسال شد.';
  }

  @override
  String get authLogout => 'خروج';

  @override
  String get accountSecurityTitle => 'امنیت حساب';

  @override
  String get accountSecurityAction => 'امنیت حساب';

  @override
  String accountIdLabel(String accountId) {
    return 'شناسه حساب: $accountId';
  }

  @override
  String get accountSessionsTitle => 'نشست‌های فعال';

  @override
  String get accountSessionsEmpty => 'نشست فعالی یافت نشد.';

  @override
  String get accountSessionDevice => 'دستگاه';

  @override
  String get accountSessionCurrent => 'نشست فعلی';

  @override
  String get accountRevokeSession => 'لغو نشست';

  @override
  String get accountLogoutAll => 'خروج از همه دستگاه‌ها';

  @override
  String get authErrorInvalidCredentials => 'اطلاعات ورود نادرست است.';

  @override
  String get authErrorChallengeExpired =>
      'کد منقضی شده است. دوباره درخواست کنید.';

  @override
  String get authErrorChallengeInvalid => 'کد نادرست است.';

  @override
  String get authErrorRateLimited =>
      'تعداد درخواست‌ها زیاد است. کمی بعد تلاش کنید.';

  @override
  String get authErrorConflict => 'این شناسه قبلاً استفاده شده است.';

  @override
  String get authErrorSessionRevoked =>
      'نشست شما پایان یافته است. دوباره وارد شوید.';

  @override
  String get authErrorValidation => 'اطلاعات واردشده معتبر نیست.';

  @override
  String get authErrorNetwork =>
      'ارتباط برقرار نشد. اتصال اینترنت را بررسی کنید.';

  @override
  String get authErrorGeneric => 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
}

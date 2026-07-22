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

  @override
  String get authStartupLoading => 'در حال بازیابی نشست…';

  @override
  String get authStartupError =>
      'بازیابی نشست ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String get authRetry => 'تلاش دوباره';

  @override
  String get authMethodTitle => 'ورود به لفوریکا';

  @override
  String get authMethodSubtitle => 'یکی از روش‌های ورود را انتخاب کنید.';

  @override
  String get authContinueWithPhone => 'ادامه با شماره موبایل';

  @override
  String get authContinueWithEmail => 'ادامه با ایمیل و رمز عبور';

  @override
  String get authPhoneTitle => 'ورود با موبایل';

  @override
  String get authPhoneLabel => 'شماره موبایل';

  @override
  String get authEmailTitle => 'ورود با ایمیل';

  @override
  String get authEmailLabel => 'ایمیل';

  @override
  String get authPasswordLabel => 'رمز عبور';

  @override
  String get authNewPasswordLabel => 'رمز عبور جدید';

  @override
  String get authOtpLabel => 'کد تأیید';

  @override
  String get authSendCode => 'ارسال کد';

  @override
  String get authVerifyCode => 'تأیید کد';

  @override
  String get authResendCode => 'ارسال مجدد کد';

  @override
  String get authPleaseWait => 'لطفاً صبر کنید…';

  @override
  String get authSignUp => 'ثبت‌نام';

  @override
  String get authSignIn => 'ورود';

  @override
  String get authForgotPassword => 'فراموشی رمز عبور';

  @override
  String get authPasswordResetTitle => 'بازیابی رمز عبور';

  @override
  String get authResetPassword => 'تنظیم رمز جدید';

  @override
  String get authPasswordResetSuccess =>
      'رمز عبور به‌روز شد. اکنون می‌توانید وارد شوید.';

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
  String accountPhoneAttached(String phone) {
    return 'موبایل تأییدشده: $phone';
  }

  @override
  String get accountPhoneMissing => 'موبایل متصل نیست';

  @override
  String accountEmailAttached(String email) {
    return 'ایمیل تأییدشده: $email';
  }

  @override
  String get accountEmailMissing => 'ایمیل متصل نیست';

  @override
  String get accountAttachEmailTitle => 'اتصال ایمیل و رمز عبور';

  @override
  String get accountAttachPhoneTitle => 'اتصال شماره موبایل';

  @override
  String get accountRemoveEmail => 'حذف ایمیل';

  @override
  String get accountRemovePhone => 'حذف موبایل';

  @override
  String get accountSessionsTitle => 'نشست‌های فعال';

  @override
  String get accountSessionDevice => 'دستگاه';

  @override
  String get accountSessionCurrent => 'نشست فعلی';

  @override
  String get accountRevokeSession => 'لغو نشست';

  @override
  String get accountLogoutAll => 'خروج از همه دستگاه‌ها';

  @override
  String get accountChangePasswordTitle => 'تغییر رمز عبور';

  @override
  String get accountCurrentPasswordLabel => 'رمز عبور فعلی';

  @override
  String get accountChangePasswordAction => 'به‌روزرسانی رمز عبور';

  @override
  String get accountChangePasswordSuccess =>
      'رمز عبور به‌روز شد. لطفاً دوباره وارد شوید.';

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
  String get authErrorLastCredential => 'نمی‌توان آخرین روش ورود را حذف کرد.';

  @override
  String get authErrorValidation => 'اطلاعات واردشده معتبر نیست.';

  @override
  String get authErrorNetwork =>
      'ارتباط برقرار نشد. اتصال اینترنت را بررسی کنید.';

  @override
  String get authErrorGeneric => 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
}

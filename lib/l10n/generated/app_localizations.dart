import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fa')];

  /// Application display title
  ///
  /// In fa, this message translates to:
  /// **'لفوریکا'**
  String get appTitle;

  /// Minimal Home screen message for M0
  ///
  /// In fa, this message translates to:
  /// **'لفوریکا آماده است'**
  String get homeWelcomeMessage;

  /// Fatal startup failure title
  ///
  /// In fa, this message translates to:
  /// **'راه‌اندازی ناموفق'**
  String get fatalStartupTitle;

  /// Fatal startup failure body without technical details
  ///
  /// In fa, this message translates to:
  /// **'پیکربندی برنامه معتبر نیست. لطفاً دوباره تلاش کنید یا با پشتیبانی تماس بگیرید.'**
  String get fatalStartupMessage;

  /// No description provided for @authStartupLoading.
  ///
  /// In fa, this message translates to:
  /// **'در حال بازیابی نشست…'**
  String get authStartupLoading;

  /// No description provided for @authStartupError.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی نشست ممکن نشد. اتصال را بررسی کنید و دوباره تلاش کنید.'**
  String get authStartupError;

  /// No description provided for @authRetry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get authRetry;

  /// No description provided for @authMethodTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود به لفوریکا'**
  String get authMethodTitle;

  /// No description provided for @authMethodSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'یکی از روش‌های ورود را انتخاب کنید.'**
  String get authMethodSubtitle;

  /// No description provided for @authContinueWithPhone.
  ///
  /// In fa, this message translates to:
  /// **'ادامه با شماره موبایل'**
  String get authContinueWithPhone;

  /// No description provided for @authContinueWithEmail.
  ///
  /// In fa, this message translates to:
  /// **'ادامه با ایمیل و رمز عبور'**
  String get authContinueWithEmail;

  /// No description provided for @authPhoneTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با موبایل'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل'**
  String get authPhoneLabel;

  /// No description provided for @authEmailTitle.
  ///
  /// In fa, this message translates to:
  /// **'ورود با ایمیل'**
  String get authEmailTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور'**
  String get authPasswordLabel;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور جدید'**
  String get authNewPasswordLabel;

  /// No description provided for @authOtpLabel.
  ///
  /// In fa, this message translates to:
  /// **'کد تأیید'**
  String get authOtpLabel;

  /// No description provided for @authSendCode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال کد'**
  String get authSendCode;

  /// No description provided for @authVerifyCode.
  ///
  /// In fa, this message translates to:
  /// **'تأیید کد'**
  String get authVerifyCode;

  /// No description provided for @authResendCode.
  ///
  /// In fa, this message translates to:
  /// **'ارسال مجدد کد'**
  String get authResendCode;

  /// Resend cooldown remaining seconds
  ///
  /// In fa, this message translates to:
  /// **'ارسال مجدد تا {seconds} ثانیه'**
  String authResendInSeconds(int seconds);

  /// No description provided for @authPleaseWait.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً صبر کنید…'**
  String get authPleaseWait;

  /// No description provided for @authSignUp.
  ///
  /// In fa, this message translates to:
  /// **'ثبت‌نام'**
  String get authSignUp;

  /// No description provided for @authSignIn.
  ///
  /// In fa, this message translates to:
  /// **'ورود'**
  String get authSignIn;

  /// No description provided for @authForgotPassword.
  ///
  /// In fa, this message translates to:
  /// **'فراموشی رمز عبور'**
  String get authForgotPassword;

  /// No description provided for @authPasswordResetTitle.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی رمز عبور'**
  String get authPasswordResetTitle;

  /// No description provided for @authResetPassword.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم رمز جدید'**
  String get authResetPassword;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور به‌روز شد. اکنون می‌توانید وارد شوید.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authCodeSentTo.
  ///
  /// In fa, this message translates to:
  /// **'کد به {destination} ارسال شد.'**
  String authCodeSentTo(String destination);

  /// No description provided for @authLogout.
  ///
  /// In fa, this message translates to:
  /// **'خروج'**
  String get authLogout;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In fa, this message translates to:
  /// **'امنیت حساب'**
  String get accountSecurityTitle;

  /// No description provided for @accountSecurityAction.
  ///
  /// In fa, this message translates to:
  /// **'امنیت حساب'**
  String get accountSecurityAction;

  /// No description provided for @accountIdLabel.
  ///
  /// In fa, this message translates to:
  /// **'شناسه حساب: {accountId}'**
  String accountIdLabel(String accountId);

  /// No description provided for @accountPhoneAttached.
  ///
  /// In fa, this message translates to:
  /// **'موبایل تأییدشده: {phone}'**
  String accountPhoneAttached(String phone);

  /// No description provided for @accountPhoneMissing.
  ///
  /// In fa, this message translates to:
  /// **'موبایل متصل نیست'**
  String get accountPhoneMissing;

  /// No description provided for @accountEmailAttached.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل تأییدشده: {email}'**
  String accountEmailAttached(String email);

  /// No description provided for @accountEmailMissing.
  ///
  /// In fa, this message translates to:
  /// **'ایمیل متصل نیست'**
  String get accountEmailMissing;

  /// No description provided for @accountAttachEmailTitle.
  ///
  /// In fa, this message translates to:
  /// **'اتصال ایمیل و رمز عبور'**
  String get accountAttachEmailTitle;

  /// No description provided for @accountAttachPhoneTitle.
  ///
  /// In fa, this message translates to:
  /// **'اتصال شماره موبایل'**
  String get accountAttachPhoneTitle;

  /// No description provided for @accountRemoveEmail.
  ///
  /// In fa, this message translates to:
  /// **'حذف ایمیل'**
  String get accountRemoveEmail;

  /// No description provided for @accountRemovePhone.
  ///
  /// In fa, this message translates to:
  /// **'حذف موبایل'**
  String get accountRemovePhone;

  /// No description provided for @accountSessionsTitle.
  ///
  /// In fa, this message translates to:
  /// **'نشست‌های فعال'**
  String get accountSessionsTitle;

  /// No description provided for @accountSessionDevice.
  ///
  /// In fa, this message translates to:
  /// **'دستگاه'**
  String get accountSessionDevice;

  /// No description provided for @accountSessionCurrent.
  ///
  /// In fa, this message translates to:
  /// **'نشست فعلی'**
  String get accountSessionCurrent;

  /// No description provided for @accountRevokeSession.
  ///
  /// In fa, this message translates to:
  /// **'لغو نشست'**
  String get accountRevokeSession;

  /// No description provided for @accountLogoutAll.
  ///
  /// In fa, this message translates to:
  /// **'خروج از همه دستگاه‌ها'**
  String get accountLogoutAll;

  /// No description provided for @accountChangePasswordTitle.
  ///
  /// In fa, this message translates to:
  /// **'تغییر رمز عبور'**
  String get accountChangePasswordTitle;

  /// No description provided for @accountCurrentPasswordLabel.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور فعلی'**
  String get accountCurrentPasswordLabel;

  /// No description provided for @accountChangePasswordAction.
  ///
  /// In fa, this message translates to:
  /// **'به‌روزرسانی رمز عبور'**
  String get accountChangePasswordAction;

  /// No description provided for @accountChangePasswordSuccess.
  ///
  /// In fa, this message translates to:
  /// **'رمز عبور به‌روز شد. لطفاً دوباره وارد شوید.'**
  String get accountChangePasswordSuccess;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات ورود نادرست است.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorChallengeExpired.
  ///
  /// In fa, this message translates to:
  /// **'کد منقضی شده است. دوباره درخواست کنید.'**
  String get authErrorChallengeExpired;

  /// No description provided for @authErrorChallengeInvalid.
  ///
  /// In fa, this message translates to:
  /// **'کد نادرست است.'**
  String get authErrorChallengeInvalid;

  /// No description provided for @authErrorRateLimited.
  ///
  /// In fa, this message translates to:
  /// **'تعداد درخواست‌ها زیاد است. کمی بعد تلاش کنید.'**
  String get authErrorRateLimited;

  /// No description provided for @authErrorConflict.
  ///
  /// In fa, this message translates to:
  /// **'این شناسه قبلاً استفاده شده است.'**
  String get authErrorConflict;

  /// No description provided for @authErrorSessionRevoked.
  ///
  /// In fa, this message translates to:
  /// **'نشست شما پایان یافته است. دوباره وارد شوید.'**
  String get authErrorSessionRevoked;

  /// No description provided for @authErrorLastCredential.
  ///
  /// In fa, this message translates to:
  /// **'نمی‌توان آخرین روش ورود را حذف کرد.'**
  String get authErrorLastCredential;

  /// No description provided for @authErrorValidation.
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات واردشده معتبر نیست.'**
  String get authErrorValidation;

  /// No description provided for @authErrorNetwork.
  ///
  /// In fa, this message translates to:
  /// **'ارتباط برقرار نشد. اتصال اینترنت را بررسی کنید.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In fa, this message translates to:
  /// **'خطایی رخ داد. لطفاً دوباره تلاش کنید.'**
  String get authErrorGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

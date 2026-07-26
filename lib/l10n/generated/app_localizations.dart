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

  /// Home welcome title for guest-accessible discovery shell
  ///
  /// In fa, this message translates to:
  /// **'به لفوریکا خوش آمدید'**
  String get homeWelcomeTitle;

  /// Home welcome subtitle explaining available areas
  ///
  /// In fa, this message translates to:
  /// **'از اینجا به بخش‌های در دسترس لفوریکا دسترسی دارید.'**
  String get homeWelcomeSubtitle;

  /// Home quick-action section title
  ///
  /// In fa, this message translates to:
  /// **'دسترسی سریع'**
  String get homeAvailableSectionsTitle;

  /// Home destination title for account security
  ///
  /// In fa, this message translates to:
  /// **'امنیت حساب'**
  String get homeAccountSecurityTitle;

  /// Home destination description for account security sessions
  ///
  /// In fa, this message translates to:
  /// **'نشست‌های فعال را مدیریت کنید و از حساب خارج شوید.'**
  String get homeAccountSecurityDescription;

  /// Semantic label for opening account security from Home
  ///
  /// In fa, this message translates to:
  /// **'باز کردن امنیت حساب'**
  String get homeOpenAccountSecurity;

  /// Home logout icon tooltip and semantic label
  ///
  /// In fa, this message translates to:
  /// **'خروج از حساب'**
  String get homeLogoutTooltip;

  /// Bottom dock semantic label for Home
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get shellHomeLabel;

  /// Bottom dock semantic label for Profile
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get shellProfileLabel;

  /// Profile screen title
  ///
  /// In fa, this message translates to:
  /// **'پروفایل'**
  String get profileTitle;

  /// Guest Profile introduction above direct phone OTP
  ///
  /// In fa, this message translates to:
  /// **'برای مدیریت پروفایل با شماره موبایل وارد شوید.'**
  String get profileGuestIntro;

  /// Semantic label for non-interactive avatar placeholder
  ///
  /// In fa, this message translates to:
  /// **'تصویر نمایه'**
  String get profileAvatarSemantic;

  /// First name field label
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get profileFirstNameLabel;

  /// Last name field label
  ///
  /// In fa, this message translates to:
  /// **'نام خانوادگی'**
  String get profileLastNameLabel;

  /// Read-only verified phone label
  ///
  /// In fa, this message translates to:
  /// **'شماره موبایل تأییدشده'**
  String get profilePhoneLabel;

  /// Verified phone indicator semantic label
  ///
  /// In fa, this message translates to:
  /// **'تأییدشده'**
  String get profilePhoneVerified;

  /// Optional contact email field label
  ///
  /// In fa, this message translates to:
  /// **'ایمیل تماس (اختیاری)'**
  String get profileEmailLabel;

  /// Contact email verification status when verified
  ///
  /// In fa, this message translates to:
  /// **'ایمیل تأیید شده است'**
  String get profileEmailVerified;

  /// Contact email verification status when unverified
  ///
  /// In fa, this message translates to:
  /// **'ایمیل تماس تأیید نشده است'**
  String get profileEmailUnverified;

  /// Profile save button label
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get profileSave;

  /// Profile save in-progress label
  ///
  /// In fa, this message translates to:
  /// **'در حال ذخیره…'**
  String get profileSaving;

  /// Profile save success feedback
  ///
  /// In fa, this message translates to:
  /// **'پروفایل ذخیره شد.'**
  String get profileSaved;

  /// Retry after profile load failure
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get profileRetry;

  /// Duplicate contact email conflict
  ///
  /// In fa, this message translates to:
  /// **'این ایمیل برای حساب دیگری ثبت شده است.'**
  String get profileErrorEmailInUse;

  /// Profile validation failure
  ///
  /// In fa, this message translates to:
  /// **'اطلاعات پروفایل معتبر نیست.'**
  String get profileErrorValidation;

  /// Profile network failure
  ///
  /// In fa, this message translates to:
  /// **'ارتباط برقرار نشد. اتصال اینترنت را بررسی کنید.'**
  String get profileErrorNetwork;

  /// Generic profile failure
  ///
  /// In fa, this message translates to:
  /// **'ذخیره پروفایل ممکن نشد. لطفاً دوباره تلاش کنید.'**
  String get profileErrorGeneric;

  /// Profile header Settings action tooltip (fixture/tests)
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get profileSettingsTooltip;

  /// Profile header Notifications action tooltip (fixture/tests)
  ///
  /// In fa, this message translates to:
  /// **'اعلان‌ها'**
  String get profileNotificationsTooltip;

  /// Accessible label for the Home search field
  ///
  /// In fa, this message translates to:
  /// **'جستجو'**
  String get shellSearchLabel;

  /// Hint text for the Home discovery search field
  ///
  /// In fa, this message translates to:
  /// **'جستجو در بخش‌های خانه'**
  String get shellSearchHint;

  /// Semantic label for clearing the Home search field
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن جستجو'**
  String get shellSearchClear;

  /// Empty state when Home search matches no discovery entries
  ///
  /// In fa, this message translates to:
  /// **'موردی یافت نشد.'**
  String get shellSearchNoResults;

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

  /// No description provided for @accountSessionsTitle.
  ///
  /// In fa, this message translates to:
  /// **'نشست‌های فعال'**
  String get accountSessionsTitle;

  /// No description provided for @accountSessionsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'نشست فعالی یافت نشد.'**
  String get accountSessionsEmpty;

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

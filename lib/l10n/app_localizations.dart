import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'eeFood'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @fontSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSmall;

  /// No description provided for @fontMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontMedium;

  /// No description provided for @fontLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontLarge;

  /// No description provided for @fontExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontExtraLarge;

  /// No description provided for @fontPreview.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog.'**
  String get fontPreview;

  /// No description provided for @fontSizeHint.
  ///
  /// In en, this message translates to:
  /// **'This size will apply across the app'**
  String get fontSizeHint;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @memberLabel.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get memberLabel;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editProfile;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get currentPlan;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @tryPlusTitle.
  ///
  /// In en, this message translates to:
  /// **'Try all Plus features free for 7 days!'**
  String get tryPlusTitle;

  /// No description provided for @tryPlusButton.
  ///
  /// In en, this message translates to:
  /// **'Try for free'**
  String get tryPlusButton;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get manageAccount;

  /// No description provided for @foodPreference.
  ///
  /// In en, this message translates to:
  /// **'Food Preferences'**
  String get foodPreference;

  /// No description provided for @foodPreferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Applied to Suggested for You tab'**
  String get foodPreferenceHint;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue With Google'**
  String get continueWithGoogle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get username;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.\nWe will send an OTP code for verification'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailEmpty;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPassword;

  /// No description provided for @createNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get createNewPasswordSubtitle;

  /// No description provided for @passwordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordEmpty;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Confirm password cannot be empty'**
  String get confirmPasswordEmpty;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get resetPasswordSuccessTitle;

  /// No description provided for @resetPasswordSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated'**
  String get resetPasswordSuccessDesc;

  /// No description provided for @goToHome.
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get goToHome;

  /// No description provided for @verificationOtp.
  ///
  /// In en, this message translates to:
  /// **'Verification OTP'**
  String get verificationOtp;

  /// No description provided for @verificationOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email and enter\n a code below'**
  String get verificationOtpSubtitle;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get otpInvalid;

  /// No description provided for @otpVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP successfully'**
  String get otpVerifiedSuccess;

  /// No description provided for @otpVerifiedFailed.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP failed'**
  String get otpVerifiedFailed;

  /// No description provided for @otpResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive email?\nYou can resend code in {seconds} s'**
  String otpResendCountdown(int seconds);

  /// No description provided for @otpGetAgain.
  ///
  /// In en, this message translates to:
  /// **'Get OTP again'**
  String get otpGetAgain;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to '**
  String get welcomeTo;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experience Expert Food'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I Already Have an Account'**
  String get alreadyHaveAccount;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @allergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Select ingredients you\'re allergic to'**
  String get allergyTitle;

  /// No description provided for @allergyDesc.
  ///
  /// In en, this message translates to:
  /// **'List ingredients that may cause allergies.\nYou can skip if you have none.'**
  String get allergyDesc;

  /// No description provided for @cuisineTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your favorite cuisines'**
  String get cuisineTitle;

  /// No description provided for @cuisineDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred cuisines for better recommendations or you can skip.'**
  String get cuisineDesc;

  /// No description provided for @dietaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred dietary plan'**
  String get dietaryTitle;

  /// No description provided for @dietaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your current dietary plan.\nYou can skip this step.'**
  String get dietaryDesc;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed!'**
  String get saveFailed;

  /// No description provided for @languagePageSubTile.
  ///
  /// In en, this message translates to:
  /// **'Choose the display language in the app.'**
  String get languagePageSubTile;

  /// No description provided for @optionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a feature'**
  String get optionTitle;

  /// No description provided for @subOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with the image?'**
  String get subOptionTitle;

  /// No description provided for @lookUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Find a dish'**
  String get lookUpTitle;

  /// No description provided for @lookUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take or select a photo to find related recipes'**
  String get lookUpSubtitle;

  /// No description provided for @analyzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition analysis'**
  String get analyzeTitle;

  /// No description provided for @analyzeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze calories, protein, fat, and micronutrients in detail'**
  String get analyzeSubtitle;

  /// No description provided for @analyzeNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition analysis'**
  String get analyzeNutritionTitle;

  /// No description provided for @analyzeNutritionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place the dish within the frame to analyze'**
  String get analyzeNutritionSubtitle;

  /// No description provided for @processingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingNutrition;

  /// No description provided for @loadingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Uploading image for analysis'**
  String get loadingNutrition;

  /// No description provided for @loadingDetectNutrition.
  ///
  /// In en, this message translates to:
  /// **'AI is detecting nutritional components'**
  String get loadingDetectNutrition;

  /// No description provided for @failAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get failAnalysis;

  /// No description provided for @retryAnalyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Please try again with a clearer image.'**
  String get retryAnalyzeImage;

  /// No description provided for @retryCapture.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retryCapture;

  /// No description provided for @healthyScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthyScoreTitle;

  /// No description provided for @allocateNutrient.
  ///
  /// In en, this message translates to:
  /// **'Nutrient Distribution'**
  String get allocateNutrient;

  /// No description provided for @interactChart.
  ///
  /// In en, this message translates to:
  /// **'Tap the chart to see details'**
  String get interactChart;

  /// No description provided for @elementNutrient.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Components'**
  String get elementNutrient;

  /// No description provided for @adviceOfPhD.
  ///
  /// In en, this message translates to:
  /// **'AI Expert Advice'**
  String get adviceOfPhD;

  /// No description provided for @nutrientOfIngredient.
  ///
  /// In en, this message translates to:
  /// **'Nutrition by Ingredients'**
  String get nutrientOfIngredient;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

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

  /// No description provided for @qrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get qrTitle;

  /// No description provided for @qrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View recipe detail from QR Code'**
  String get qrSubtitle;

  /// No description provided for @mealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlanTitle;

  /// No description provided for @mealPlanNoPlan.
  ///
  /// In en, this message translates to:
  /// **'There is no current meal plan yet.'**
  String get mealPlanNoPlan;

  /// No description provided for @mealPlanCreateAi.
  ///
  /// In en, this message translates to:
  /// **'Create AI plan'**
  String get mealPlanCreateAi;

  /// No description provided for @mealPlanCurrentTag.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get mealPlanCurrentTag;

  /// No description provided for @mealPlanDefaultGoal.
  ///
  /// In en, this message translates to:
  /// **'Maintain balanced meals every day'**
  String get mealPlanDefaultGoal;

  /// No description provided for @mealPlanOverviewByDay.
  ///
  /// In en, this message translates to:
  /// **'Daily overview'**
  String get mealPlanOverviewByDay;

  /// No description provided for @mealPlanNoDailySummary.
  ///
  /// In en, this message translates to:
  /// **'No daily nutrition summary is available for the current meal plan.'**
  String get mealPlanNoDailySummary;

  /// No description provided for @mealPlanActionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Meal plan actions'**
  String get mealPlanActionTooltip;

  /// No description provided for @mealPlanNoPlanToUpdate.
  ///
  /// In en, this message translates to:
  /// **'There is no meal plan to update'**
  String get mealPlanNoPlanToUpdate;

  /// No description provided for @mealPlanNoPlanToContinue.
  ///
  /// In en, this message translates to:
  /// **'There is no meal plan to continue'**
  String get mealPlanNoPlanToContinue;

  /// No description provided for @mealPlanDeleteNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Backend does not support deleting meal plans yet'**
  String get mealPlanDeleteNotSupported;

  /// No description provided for @mealPlanUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update meal plan'**
  String get mealPlanUpdateAction;

  /// No description provided for @mealPlanContinueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue meal plan'**
  String get mealPlanContinueAction;

  /// No description provided for @mealPlanDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete meal plan'**
  String get mealPlanDeleteAction;

  /// No description provided for @mealPlanContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue meal plan'**
  String get mealPlanContinueTitle;

  /// No description provided for @mealPlanContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a start date and number of days for AI to continue the plan.'**
  String get mealPlanContinueSubtitle;

  /// No description provided for @mealPlanStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get mealPlanStartDate;

  /// No description provided for @mealPlanDays.
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get mealPlanDays;

  /// No description provided for @mealPlanDaysExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 3'**
  String get mealPlanDaysExample;

  /// No description provided for @mealPlanInvalidDays.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of days'**
  String get mealPlanInvalidDays;

  /// No description provided for @mealPlanContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get mealPlanContinueButton;

  /// No description provided for @mealPlanGenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create AI plan'**
  String get mealPlanGenerateTitle;

  /// No description provided for @mealPlanGenerateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal, start date, and number of days for AI to create your meal plan.'**
  String get mealPlanGenerateSubtitle;

  /// No description provided for @mealPlanGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get mealPlanGoal;

  /// No description provided for @mealPlanGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Lose weight, eat balanced meals, build muscle...'**
  String get mealPlanGoalHint;

  /// No description provided for @mealPlanDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 days per generation'**
  String get mealPlanDaysHint;

  /// No description provided for @mealPlanInvalidGenerateInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter all valid required information'**
  String get mealPlanInvalidGenerateInput;

  /// No description provided for @mealPlanCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get mealPlanCreateButton;

  /// No description provided for @mealPlanUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update meal plan'**
  String get mealPlanUpdateTitle;

  /// No description provided for @mealPlanUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get mealPlanUpdateButton;

  /// No description provided for @mealPlanGoalHintShort.
  ///
  /// In en, this message translates to:
  /// **'Example: Balanced eating, build muscle, lose weight'**
  String get mealPlanGoalHintShort;

  /// No description provided for @mealPlanEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get mealPlanEndDate;

  /// No description provided for @mealPlanNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get mealPlanNote;

  /// No description provided for @mealPlanHealthNote.
  ///
  /// In en, this message translates to:
  /// **'Health note'**
  String get mealPlanHealthNote;

  /// No description provided for @mealPlanEndDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'End date must be after or equal to start date'**
  String get mealPlanEndDateInvalid;

  /// No description provided for @mealPlanCurrentSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get mealPlanCurrentSummaryTitle;

  /// No description provided for @mealPlanViewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get mealPlanViewing;

  /// No description provided for @mealPlanNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get mealPlanNew;

  /// No description provided for @mealPlanProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get mealPlanProtein;

  /// No description provided for @mealPlanCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get mealPlanCarbs;

  /// No description provided for @mealPlanFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get mealPlanFat;

  /// No description provided for @mealPlanFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get mealPlanFiber;

  /// No description provided for @mealPlanUnnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed meal'**
  String get mealPlanUnnamedItem;

  /// No description provided for @mealPlanCannotDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete this meal'**
  String get mealPlanCannotDeleteItem;

  /// No description provided for @mealPlanDeleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get mealPlanDeleteItemTitle;

  /// No description provided for @mealPlanDeleteItemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{itemName}\" from the meal plan?'**
  String mealPlanDeleteItemMessage(String itemName);

  /// No description provided for @mealPlanNoItemsForDay.
  ///
  /// In en, this message translates to:
  /// **'There are no meals for this day yet.'**
  String get mealPlanNoItemsForDay;

  /// No description provided for @mealPlanEditItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit meal'**
  String get mealPlanEditItemTooltip;

  /// No description provided for @mealPlanDeleteItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get mealPlanDeleteItemTooltip;

  /// No description provided for @mealPlanServings.
  ///
  /// In en, this message translates to:
  /// **'Servings: {count}'**
  String mealPlanServings(String count);

  /// No description provided for @mealPlanDayItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals for the day'**
  String get mealPlanDayItemsTitle;

  /// No description provided for @mealPlanAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get mealPlanAddItem;

  /// No description provided for @mealPlanIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get mealPlanIngredientsTitle;

  /// No description provided for @mealPlanNoIngredients.
  ///
  /// In en, this message translates to:
  /// **'There are no ingredients for this meal yet.'**
  String get mealPlanNoIngredients;

  /// No description provided for @mealPlanAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get mealPlanAdd;

  /// No description provided for @mealPlanIngredientNumber.
  ///
  /// In en, this message translates to:
  /// **'Ingredient {index}'**
  String mealPlanIngredientNumber(int index);

  /// No description provided for @mealPlanDeleteIngredientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete ingredient'**
  String get mealPlanDeleteIngredientTooltip;

  /// No description provided for @mealPlanIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get mealPlanIngredientName;

  /// No description provided for @mealPlanIngredientQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get mealPlanIngredientQuantity;

  /// No description provided for @mealPlanIngredientUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get mealPlanIngredientUnit;

  /// No description provided for @mealPlanIngredientNote.
  ///
  /// In en, this message translates to:
  /// **'Ingredient note'**
  String get mealPlanIngredientNote;

  /// No description provided for @mealPlanItemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meal name'**
  String get mealPlanItemNameRequired;

  /// No description provided for @mealPlanItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal in the plan has been updated'**
  String get mealPlanItemUpdated;

  /// No description provided for @mealPlanItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Meal has been added to the plan'**
  String get mealPlanItemAdded;

  /// No description provided for @mealPlanEditItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit meal in plan'**
  String get mealPlanEditItemTitle;

  /// No description provided for @mealPlanAddItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add meal to plan'**
  String get mealPlanAddItemTitle;

  /// No description provided for @mealPlanApplyDate.
  ///
  /// In en, this message translates to:
  /// **'Apply date'**
  String get mealPlanApplyDate;

  /// No description provided for @mealPlanMealSlot.
  ///
  /// In en, this message translates to:
  /// **'Meal slot'**
  String get mealPlanMealSlot;

  /// No description provided for @mealPlanItemName.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealPlanItemName;

  /// No description provided for @mealPlanItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Grilled chicken salad'**
  String get mealPlanItemNameHint;

  /// No description provided for @mealPlanLinkedMeal.
  ///
  /// In en, this message translates to:
  /// **'Linked meal'**
  String get mealPlanLinkedMeal;

  /// No description provided for @mealPlanLinkedMealHelper.
  ///
  /// In en, this message translates to:
  /// **'The linked meal cannot be changed here'**
  String get mealPlanLinkedMealHelper;

  /// No description provided for @mealPlanPlannedServings.
  ///
  /// In en, this message translates to:
  /// **'Planned servings'**
  String get mealPlanPlannedServings;

  /// No description provided for @mealPlanActualServings.
  ///
  /// In en, this message translates to:
  /// **'Actual servings'**
  String get mealPlanActualServings;

  /// No description provided for @mealPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get mealPlanStatus;

  /// No description provided for @mealPlanSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get mealPlanSaveChanges;

  /// No description provided for @mealPlanMealSlotBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealPlanMealSlotBreakfast;

  /// No description provided for @mealPlanMealSlotLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealPlanMealSlotLunch;

  /// No description provided for @mealPlanMealSlotDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealPlanMealSlotDinner;

  /// No description provided for @mealPlanMealSlotSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealPlanMealSlotSnack;

  /// No description provided for @mealPlanStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get mealPlanStatusPlanned;

  /// No description provided for @mealPlanStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mealPlanStatusDone;

  /// No description provided for @mealPlanStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get mealPlanStatusSkipped;
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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'eeFood';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get display => 'Display';

  @override
  String get theme => 'Theme';

  @override
  String get fontSize => 'Font Size';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System Default';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontMedium => 'Medium';

  @override
  String get fontLarge => 'Large';

  @override
  String get fontExtraLarge => 'Extra Large';

  @override
  String get fontPreview => 'The quick brown fox jumps over the lazy dog.';

  @override
  String get fontSizeHint => 'This size will apply across the app';

  @override
  String get saved => 'Saved';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Confirm logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get profileTitle => 'Profile';

  @override
  String get memberLabel => 'Member';

  @override
  String get editProfile => 'Edit';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get freePlan => 'Free';

  @override
  String get tryPlusTitle => 'Try all Plus features free for 7 days!';

  @override
  String get tryPlusButton => 'Try for free';

  @override
  String get manageAccount => 'Manage Account';

  @override
  String get foodPreference => 'Food Preferences';

  @override
  String get foodPreferenceHint => 'Applied to Suggested for You tab';

  @override
  String get system => 'System';

  @override
  String get notifications => 'Notifications';

  @override
  String get support => 'Support';

  @override
  String get feedback => 'Feedback';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get about => 'About';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get rateApp => 'Rate App';

  @override
  String get accountTitle => 'Account';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get signUp => 'Sign up';

  @override
  String get continueWithGoogle => 'Continue With Google';

  @override
  String get username => 'User name';

  @override
  String get forgotPasswordSubtitle => 'Please enter your email.\nWe will send an OTP code for verification';

  @override
  String get emailEmpty => 'Email cannot be empty';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get createNewPassword => 'Create new password';

  @override
  String get createNewPasswordSubtitle => 'Enter your new password below';

  @override
  String get passwordEmpty => 'Password cannot be empty';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordEmpty => 'Confirm password cannot be empty';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetPasswordSuccessTitle => 'Success';

  @override
  String get resetPasswordSuccessDesc => 'Your password has been updated';

  @override
  String get goToHome => 'Go to home';

  @override
  String get verificationOtp => 'Verification OTP';

  @override
  String get verificationOtpSubtitle => 'Check your email and enter\n a code below';

  @override
  String get otpInvalid => 'Invalid OTP';

  @override
  String get otpVerifiedSuccess => 'Verify OTP successfully';

  @override
  String get otpVerifiedFailed => 'Verify OTP failed';

  @override
  String otpResendCountdown(int seconds) {
    return 'Didn\'t receive email?\nYou can resend code in $seconds s';
  }

  @override
  String get otpGetAgain => 'Get OTP again';

  @override
  String get welcomeTo => 'Welcome to ';

  @override
  String get welcomeSubtitle => 'Experience Expert Food';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'I Already Have an Account';

  @override
  String get skip => 'Skip';

  @override
  String get continueButton => 'Continue';

  @override
  String get finish => 'Finish';

  @override
  String get allergyTitle => 'Select ingredients you\'re allergic to';

  @override
  String get allergyDesc => 'List ingredients that may cause allergies.\nYou can skip if you have none.';

  @override
  String get cuisineTitle => 'Select your favorite cuisines';

  @override
  String get cuisineDesc => 'Choose your preferred cuisines for better recommendations or you can skip.';

  @override
  String get dietaryTitle => 'Select your preferred dietary plan';

  @override
  String get dietaryDesc => 'Choose your current dietary plan.\nYou can skip this step.';

  @override
  String get saveSuccess => 'Saved successfully';

  @override
  String get saveFailed => 'Save failed!';

  @override
  String get languagePageSubTile => 'Choose the display language in the app.';

  @override
  String get optionTitle => 'Choose a feature';

  @override
  String get subOptionTitle => 'What would you like to do with the image?';

  @override
  String get lookUpTitle => 'Find a dish';

  @override
  String get lookUpSubtitle => 'Take or select a photo to find related recipes';

  @override
  String get analyzeTitle => 'Nutrition analysis';

  @override
  String get analyzeSubtitle => 'Analyze calories, protein, fat, and micronutrients in detail';

  @override
  String get analyzeNutritionTitle => 'Nutrition analysis';

  @override
  String get analyzeNutritionSubtitle => 'Place the dish within the frame to analyze';

  @override
  String get processingNutrition => 'Processing...';

  @override
  String get loadingNutrition => 'Uploading image for analysis';

  @override
  String get loadingDetectNutrition => 'AI is detecting nutritional components';

  @override
  String get failAnalysis => 'Analysis failed';

  @override
  String get retryAnalyzeImage => 'Please try again with a clearer image.';

  @override
  String get retryCapture => 'Retake photo';

  @override
  String get healthyScoreTitle => 'Health Score';

  @override
  String get allocateNutrient => 'Nutrient Distribution';

  @override
  String get interactChart => 'Tap the chart to see details';

  @override
  String get elementNutrient => 'Nutritional Components';

  @override
  String get adviceOfPhD => 'AI Expert Advice';

  @override
  String get nutrientOfIngredient => 'Nutrition by Ingredients';

  @override
  String get qrTitle => 'Scan QR';

  @override
  String get qrSubtitle => 'View recipe detail from QR Code';

  @override
  String get mealPlanTitle => 'Meal Plan';

  @override
  String get mealPlanNoPlan => 'There is no current meal plan yet.';

  @override
  String get mealPlanCreateAi => 'Create AI plan';

  @override
  String get mealPlanCurrentTag => 'Current plan';

  @override
  String get mealPlanDefaultGoal => 'Maintain balanced meals every day';

  @override
  String get mealPlanOverviewByDay => 'Daily overview';

  @override
  String get mealPlanNoDailySummary => 'No daily nutrition summary is available for the current meal plan.';

  @override
  String get mealPlanActionTooltip => 'Meal plan actions';

  @override
  String get mealPlanNoPlanToUpdate => 'There is no meal plan to update';

  @override
  String get mealPlanNoPlanToContinue => 'There is no meal plan to continue';

  @override
  String get mealPlanDeleteNotSupported => 'Backend does not support deleting meal plans yet';

  @override
  String get mealPlanUpdateAction => 'Update meal plan';

  @override
  String get mealPlanContinueAction => 'Continue meal plan';

  @override
  String get mealPlanDeleteAction => 'Delete meal plan';

  @override
  String get mealPlanContinueTitle => 'Continue meal plan';

  @override
  String get mealPlanContinueSubtitle => 'Choose a start date and number of days for AI to continue the plan.';

  @override
  String get mealPlanStartDate => 'Start date';

  @override
  String get mealPlanDays => 'Number of days';

  @override
  String get mealPlanDaysExample => 'Example: 3';

  @override
  String get mealPlanInvalidDays => 'Please enter a valid number of days';

  @override
  String get mealPlanContinueButton => 'Continue';

  @override
  String get mealPlanGenerateTitle => 'Create AI plan';

  @override
  String get mealPlanGenerateSubtitle => 'Enter a goal, start date, and number of days for AI to create your meal plan.';

  @override
  String get mealPlanGoal => 'Goal';

  @override
  String get mealPlanGoalHint => 'Example: Lose weight, eat balanced meals, build muscle...';

  @override
  String get mealPlanDaysHint => 'Up to 5 days per generation';

  @override
  String get mealPlanInvalidGenerateInput => 'Please enter all valid required information';

  @override
  String get mealPlanCreateButton => 'Create plan';

  @override
  String get mealPlanUpdateTitle => 'Update meal plan';

  @override
  String get mealPlanUpdateButton => 'Save changes';

  @override
  String get mealPlanGoalHintShort => 'Example: Balanced eating, build muscle, lose weight';

  @override
  String get mealPlanEndDate => 'End date';

  @override
  String get mealPlanNote => 'Note';

  @override
  String get mealPlanHealthNote => 'Health note';

  @override
  String get mealPlanEndDateInvalid => 'End date must be after or equal to start date';

  @override
  String get mealPlanCurrentSummaryTitle => 'Current plan';

  @override
  String get mealPlanViewing => 'Viewing';

  @override
  String get mealPlanNew => 'New';

  @override
  String get mealPlanProtein => 'Protein';

  @override
  String get mealPlanCarbs => 'Carbs';

  @override
  String get mealPlanFat => 'Fat';

  @override
  String get mealPlanFiber => 'Fiber';

  @override
  String get mealPlanUnnamedItem => 'Unnamed meal';

  @override
  String get mealPlanCannotDeleteItem => 'Cannot delete this meal';

  @override
  String get mealPlanDeleteItemTitle => 'Delete meal';

  @override
  String mealPlanDeleteItemMessage(String itemName) {
    return 'Are you sure you want to remove \"$itemName\" from the meal plan?';
  }

  @override
  String get mealPlanNoItemsForDay => 'There are no meals for this day yet.';

  @override
  String get mealPlanEditItemTooltip => 'Edit meal';

  @override
  String get mealPlanDeleteItemTooltip => 'Delete meal';

  @override
  String mealPlanServings(String count) {
    return 'Servings: $count';
  }

  @override
  String get mealPlanDayItemsTitle => 'Meals for the day';

  @override
  String get mealPlanAddItem => 'Add meal';

  @override
  String get mealPlanIngredientsTitle => 'Ingredients';

  @override
  String get mealPlanNoIngredients => 'There are no ingredients for this meal yet.';

  @override
  String get mealPlanAdd => 'Add';

  @override
  String mealPlanIngredientNumber(int index) {
    return 'Ingredient $index';
  }

  @override
  String get mealPlanDeleteIngredientTooltip => 'Delete ingredient';

  @override
  String get mealPlanIngredientName => 'Ingredient name';

  @override
  String get mealPlanIngredientQuantity => 'Quantity';

  @override
  String get mealPlanIngredientUnit => 'Unit';

  @override
  String get mealPlanIngredientNote => 'Ingredient note';

  @override
  String get mealPlanItemNameRequired => 'Please enter a meal name';

  @override
  String get mealPlanItemUpdated => 'Meal in the plan has been updated';

  @override
  String get mealPlanItemAdded => 'Meal has been added to the plan';

  @override
  String get mealPlanEditItemTitle => 'Edit meal in plan';

  @override
  String get mealPlanAddItemTitle => 'Add meal to plan';

  @override
  String get mealPlanApplyDate => 'Apply date';

  @override
  String get mealPlanMealSlot => 'Meal slot';

  @override
  String get mealPlanItemName => 'Meal name';

  @override
  String get mealPlanItemNameHint => 'Example: Grilled chicken salad';

  @override
  String get mealPlanLinkedMeal => 'Linked meal';

  @override
  String get mealPlanLinkedMealHelper => 'The linked meal cannot be changed here';

  @override
  String get mealPlanPlannedServings => 'Planned servings';

  @override
  String get mealPlanActualServings => 'Actual servings';

  @override
  String get mealPlanStatus => 'Status';

  @override
  String get mealPlanSaveChanges => 'Save changes';

  @override
  String get mealPlanMealSlotBreakfast => 'Breakfast';

  @override
  String get mealPlanMealSlotLunch => 'Lunch';

  @override
  String get mealPlanMealSlotDinner => 'Dinner';

  @override
  String get mealPlanMealSlotSnack => 'Snack';

  @override
  String get mealPlanStatusPlanned => 'Planned';

  @override
  String get mealPlanStatusDone => 'Done';

  @override
  String get mealPlanStatusSkipped => 'Skipped';
}


import 'package:eefood/features/auth/presentation/screens/login_page.dart';
import 'package:eefood/features/auth/presentation/screens/register_page.dart';
import 'package:eefood/features/auth/presentation/screens/reset_password.dart';
import 'package:eefood/features/auth/presentation/screens/splash_page.dart';
import 'package:eefood/features/auth/presentation/screens/verify_otp.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:eefood/features/profile/presentation/screens/edit_profile_page.dart';
import 'package:eefood/features/profile/presentation/screens/food_preferences_page.dart';
import 'package:eefood/features/profile/presentation/screens/language_page.dart';
import 'package:eefood/main.dart';
import 'package:eefood/main_screen.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/forgot_password.dart';
import 'features/profile/presentation/screens/profile_page.dart';
import 'features/recipe/presentation/screens/home_page.dart';
import 'features/recipe/presentation/screens/my_recipes_page.dart';
import 'features/recipe/presentation/screens/search_page.dart';
import 'features/recipe/presentation/screens/shopping_list_page.dart';

class AppRoutes {
  static const myApp = '/myapp';
  static const main = '/main';
  /* feat auth*/
  static const login = '/login';
  static const welcome = '/welcome';
  static const splashPage = '/splashPage'; //trang load dau
  static const register = '/register';
  static const verifyOtp = '/verifyOtp';
  static const forgotPassword = '/forgotPassword';
  static const resetPassword = '/resetPassword';


  /* feat profile*/
  static const editProfile = '/editProfile';
  static const foodPreference = '/foodPreference';
  static const language = '/language';

  // Danh sách các widget cho BottomNavigationBar trong main page
  static List<Widget> widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    MyRecipesPage(),
    ShoppingListPage(),
    ProfilePage(),
  ];

  static final Map<String, WidgetBuilder> listRoute = {
    myApp: (context) => const MyApp(),
    main: (context) => const MainScreen(),
    login: (context) => LoginPage(),
    welcome: (context) => const WelcomePage(),
    splashPage: (context) => const SplashPage(),
    editProfile: (context) => const EditProfilePage(),
    foodPreference: (context) => const FoodPreferencesPage(),
    language: (context) => const LanguagePage(),
    register: (context) => RegisterPage(),
    verifyOtp: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return VerificationOtpPage(
        email: args['email'],
        otpType: args['otpType'],
      );
    },
    forgotPassword: (context) => ForgotPasswordPage(),
    resetPassword: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ResetPasswordPage(
        email: args['email'],
        otpCode: args['otpCode'],
      );
    },
  };
}
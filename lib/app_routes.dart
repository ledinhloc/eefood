import 'package:eefood/core/widgets/error_page.dart';
import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:eefood/features/auth/presentation/bloc/on_boarding_bloc/on_boarding_cubit.dart';
import 'package:eefood/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:eefood/features/auth/presentation/screens/login_page.dart';
import 'package:eefood/features/auth/presentation/screens/on_boarding_flow_page.dart';
import 'package:eefood/features/auth/presentation/screens/register_page.dart';
import 'package:eefood/features/auth/presentation/screens/reset_password_page.dart';
import 'package:eefood/features/auth/presentation/screens/splash_page.dart';
import 'package:eefood/features/auth/presentation/screens/verify_otp_page.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:eefood/features/noti/presentation/provider/notification_cubit.dart';
import 'package:eefood/features/noti/presentation/screens/notification_screen.dart';
import 'package:eefood/features/noti/presentation/screens/ntofication_settings_screen.dart';
import 'package:eefood/features/post/presentation/screens/collection_detail_page.dart';
import 'package:eefood/features/post/presentation/screens/collection_list_page.dart';
import 'package:eefood/features/post/presentation/screens/feed_screen.dart';
import 'package:eefood/features/profile/presentation/screens/edit_profile_page.dart';
import 'package:eefood/features/profile/presentation/screens/food_preferences_page.dart';
import 'package:eefood/features/profile/presentation/screens/language_page.dart';
import 'package:eefood/features/recipe/data/models/recipe_model.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_crud_page.dart';
import 'package:eefood/features/recipe/presentation/screens/recipe_detail_page.dart';
import 'package:eefood/main.dart';
import 'package:eefood/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/profile/presentation/screens/profile_page.dart';
import 'features/recipe/presentation/screens/my_recipes_page.dart';
import 'features/recipe/presentation/screens/search_page.dart';
import 'features/recipe/presentation/screens/shopping_page.dart';

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
  static const onBoardingFlow = '/onBoardingFlow';
  static const errorPage = '/errorPage';

  /* feat profile*/
  static const editProfile = '/editProfile';
  static const foodPreference = '/foodPreference';
  static const language = '/language';
  static const mediaView = '/mediaView';

  /* feat recipe */
  static const recipeCrudPage = '/recipeCrudPage';
  static const recipeDetail = '/recipeDetail';

  /*feat notification*/
  static const notificationSettingScreen = '/notificationSettingsScreen';
  static const notificationScreen = '/notificationScreen';

  /* feat post */
  static const collectionList = '/collectionList';
  static const collectionDetail = '/collectionDetail';

  // Danh sách các widget cho BottomNavigationBar trong main page
  static List<Widget> widgetOptions = <Widget>[
    FeedScreen(),
    CollectionListPage(),
    MyRecipesPage(),
    ShoppingPage(),
    ProfilePage(),
  ];

  static final Map<String, WidgetBuilder> listRoute = {
    myApp: (context) => const MyApp(),
    main: (context) => const MainScreen(),
    login: (context) => LoginPage(),
    welcome: (context) => const WelcomePage(),
    splashPage: (context) => const SplashPage(),
    editProfile: (context) {
      final user = ModalRoute.of(context)!.settings.arguments as User;
      return EditProfilePage(user: user);
    },
    foodPreference: (context) => const FoodPreferencesPage(),
    language: (context) => const LanguagePage(),
    register: (context) => RegisterPage(),
    verifyOtp: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return VerificationOtpPage(
        email: args['email'],
        otpType: args['otpType'],
      );
    },
    forgotPassword: (context) => ForgotPasswordPage(),
    resetPassword: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ResetPasswordPage(email: args['email'], otpCode: args['otpCode']);
    },
    onBoardingFlow: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return BlocProvider(
        create: (_) => OnBoardingCubit(),
        child: OnBoardingFlowPage(),
      );
    },
    mediaView: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return MediaViewPage(
        isVideo: args['isVideo'],
        isLocal: args['isLocal'] ?? false,
        url: args['url'],
      );
    },
    recipeCrudPage: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final recipe = args?['initialRecipe'] as RecipeModel?;
      final isCreate = args?['isCreate'] as bool? ?? true;
      return RecipeCreatePage(isCreate: isCreate, initialRecipe: recipe);
    },
    errorPage: (context) => ErrorPage(),
    notificationScreen: (context) => NotificationScreen(),
    notificationSettingScreen: (context) => const NotificationSettingsScreen(),
    recipeDetail: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final recipeId = args['recipeId'] as int;
      return RecipeDetailPage(recipeId: recipeId);
    },
    //post,
    collectionList: (context) => CollectionListPage(),
    collectionDetail: (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return CollectionDetailPage(collectionId: args['collectionId']);
    }
  };
}

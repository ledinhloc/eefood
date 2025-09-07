
import 'package:eefood/features/auth/presentation/screens/login_page.dart';
import 'package:eefood/features/auth/presentation/screens/splash_page.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:eefood/main.dart';
import 'package:eefood/main_screen.dart';
import 'package:flutter/material.dart';

import 'features/profile/presentation/screens/profile_page.dart';
import 'features/recipe/presentation/screens/home_page.dart';
import 'features/recipe/presentation/screens/my_recipes_page.dart';
import 'features/recipe/presentation/screens/search_page.dart';
import 'features/recipe/presentation/screens/shopping_list_page.dart';

class AppRoutes{
  static const myApp = '/myapp';
  static const main = '/main';
  static const login = '/login';
  static const welcome = '/welcome';
  static const splashPage = '/splashPage'; //trang load dau

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
  };
}
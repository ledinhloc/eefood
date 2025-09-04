import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/features/auth/presentation/screens/splash_page.dart';
import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_themes.dart';
import 'core/di/injection.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/profile/presentation/screens/profile_page.dart';
import 'features/recipe/presentation/screens/home_page.dart';
import 'features/recipe/presentation/screens/my_recipes_page.dart';
import 'features/recipe/presentation/screens/search_page.dart';
import 'features/recipe/presentation/screens/shopping_list_page.dart';
import 'package:flutter/services.dart';
/*
  Định nghĩa các route và theme App
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // làm trong suốt
    statusBarIconBrightness: Brightness.dark, // icon màu đen
    statusBarBrightness: Brightness.light, // cho iOS
  ));
  await di.setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  //Danh sach cac pages
  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    MyRecipesPage(),
    ShoppingListPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eeFood',
      theme: appTheme(),
      home: _isLoggedIn
          ? Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyRecipes'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          currentIndex: _selectedIndex,
          // selectedItemColor: Colors.orange,
          onTap: _onItemTapped,
        ),
      )
          // : const SplashPage(),
          : const WelcomePage(),
    );
  }

  /*
  Kiểm tra login chưa
   */
  Future<void> _loadUser() async {
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _isLoggedIn = prefs.getBool(AppKeys.isLoginedIn) ?? false;
    // });

    final user = await _getCurrentUser();
    setState(() {
      _isLoggedIn = (user != null);
    });
    print(_isLoggedIn);
  }
}


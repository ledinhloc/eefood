import 'package:eefood/features/auth/presentation/screens/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_themes.dart';
import 'features/profile/presentation/screens/profile_page.dart';
import 'features/recipe/presentation/screens/home_page.dart';
import 'features/recipe/presentation/screens/my_recipes_page.dart';
import 'features/recipe/presentation/screens/search_page.dart';
import 'features/recipe/presentation/screens/shopping_list_page.dart';

/*
  Định nghĩa các route và theme App
 */
void main() {
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  //Danh sach cac pages
  static const List<Widget> _widgetOptions = <Widget>[
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
          : const WelcomePage(),
      // initialRoute: '/',
      // routes: {
      //   '/': (context) => const WelcomePage(),
      //   '/login': (context) => const LoginPage(),
      //   '/home': (context) => const HomePage(),
      //   '/search': (context) => const SearchPage(),
      //   '/myRecipes': (context) => const MyRecipesPage(),
      //   '/shoppingList': (context) => const ShoppingListPage(),
      //   '/profile': (context) => const ProfilePage(),
      //   '/notification': (context) => const NotificationPage(),
      // },
    );
  }

  /*
  Kiểm tra login chưa
   */
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }
}


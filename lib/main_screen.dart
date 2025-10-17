
import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: AppRoutes.widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'MyRecipes'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shopping List'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/widgets/show_login_required.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data;

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
            onTap: (index) => _onItemTapped(index, user, context),
          ),
        );
      },
    );
  }

  void _onItemTapped(int index, User? user,BuildContext context) {
    if (index == 0) {
      setState(() => _selectedIndex = index);
      return;
    }

    if (user == null) {
      showLoginRequired(context);
      return;
    }

    setState(() => _selectedIndex = index);
  }
}
import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_themes.dart';
import 'core/di/injection.dart';
import 'core/di/injection.dart' as di;
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'package:flutter/services.dart';
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

  bool _isLoggedIn = false;
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _getCurrentUser();
    setState(() {
      _isLoggedIn = (user != null);
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eeFood',
      theme: appTheme(),
      initialRoute: _isLoggedIn ? AppRoutes.main : AppRoutes.welcome,
      routes: AppRoutes.listRoute,
    );
  }
}


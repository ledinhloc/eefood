import 'package:eefood/app_routes.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_themes.dart';
import 'core/di/injection.dart' as di;
import 'package:flutter/services.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Status bar trong suốt
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent, // Navigation bar trong suốt
    systemNavigationBarIconBrightness: Brightness.light, // icon sáng
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'eeFood',
      theme: appTheme(),
      initialRoute: AppRoutes.onBoardingFlow,
      routes: AppRoutes.listRoute,
    );
  }
}


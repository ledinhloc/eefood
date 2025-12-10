import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/deep_link_service.dart';
import 'package:eefood/features/noti/domain/usecases/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_themes.dart';
import 'core/di/injection.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await NotificationService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Status bar trong suốt
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent, // Navigation bar trong suốt
      systemNavigationBarIconBrightness: Brightness.light, // icon sáng
    ),
  );
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

    // Future.microtask(() {
    //   di.getIt<NotificationCubit>();
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'eeFood',
      theme: appTheme(),
      initialRoute: AppRoutes.splashPage,
      routes: AppRoutes.listRoute,
    );
  }
}

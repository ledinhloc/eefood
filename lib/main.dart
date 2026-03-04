import 'package:eefood/app_routes.dart';
import 'package:eefood/core/utils/deep_link_service.dart';
import 'package:eefood/features/noti/domain/usecases/notification_service.dart';
import 'package:eefood/features/profile/presentation/provider/settings_cubit.dart';
import 'package:eefood/features/profile/presentation/provider/settings_state.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  late final SettingsCubit _settingsCubit;
  @override
  void initState() {
    super.initState();
    _settingsCubit = di.getIt<SettingsCubit>()..loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsCubit,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MediaQuery(
            // Áp dụng textScaleFactor từ settings
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(settings.textScaleFactor)),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'eeFood',
              // Theme
              theme: appTheme(), // light theme
              darkTheme: appDarkTheme(), // dark theme
              themeMode: settings.flutterThemeMode,
              // Localization
              locale: settings.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: AppRoutes.splashPage,
              routes: AppRoutes.listRoute,
            ),
          );
        },
      ),
    );
  }
}

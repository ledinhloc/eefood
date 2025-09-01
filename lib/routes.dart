import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/login_page.dart';
import 'features/auth/presentation/screens/welcome_page.dart';


final Map<String, WidgetBuilder> routes = {
  '/': (context) => const WelcomePage(),
  '/login': (context) => const LoginPage(),
};
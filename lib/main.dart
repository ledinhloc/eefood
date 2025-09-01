import 'package:eefood/routes.dart';
import 'package:eefood/widget_tree.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eeFood',
      theme: appTheme(),
      initialRoute: '/',
      routes: routes,
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: WidgetTree(),
//     );
//   }
// }

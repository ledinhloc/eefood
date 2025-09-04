import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData appTheme() {
  return ThemeData(
    /* mau chu dao dung cho: AppBar, Button */
    primaryColor: primaryColor,
    /* mau mac dinh cho scaffold */
    scaffoldBackgroundColor: backgroundColor,
    /* style mặc định cho TextField / TextFormField */
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    /* style chữ trong app */
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: textColor, fontSize: 16),
    ),
    /* style mặc định cho ElevatedButton*/
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    /*  bottomNavigationBarTheme */
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColor, // hoặc Colors.black
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

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

ThemeData appDarkTheme() {
  // Màu dark - ánh xạ 1-1 với app_colors.dart nhưng cho dark mode
  const darkPrimaryColor = primaryColor; // Giữ nguyên màu chủ đạo
  const darkBackgroundColor = Color(0xFF121212); // Nền tối
  const darkSurfaceColor = Color(0xFF1E1E1E); // Card, bottom nav
  const darkTextColor = Color(0xFFEFEFEF); // Chữ sáng
  const darkInputBorderColor = Color(0xFF3A3A3A); // Viền input

  return ThemeData(
    /* mau chu dao */
    primaryColor: darkPrimaryColor,
    /* mau nen scaffold */
    scaffoldBackgroundColor: darkBackgroundColor,
    /* style mặc định cho TextField / TextFormField */
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: darkInputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkPrimaryColor),
      ),
      filled: true,
      fillColor: darkSurfaceColor,
      hintStyle: TextStyle(color: Color(0xFF6B6B6B)),
    ),
    /* style chữ */
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkTextColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: darkTextColor, fontSize: 16),
    ),
    /* style mặc định cho ElevatedButton */
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    /* bottomNavigationBarTheme */
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: darkPrimaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

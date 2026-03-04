import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData appTheme() {
  return ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent
    ),
    cardTheme: CardThemeData(color: Colors.red[50]),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: Colors.white,
      onSurface: textColor, 
      onPrimary: Colors.white,
      primaryContainer: primaryColor.withOpacity(0.1),
    ),
    /* mau chu dao dung cho: AppBar, Button */
    primaryColor: primaryColor,
    /* mau mac dinh cho scaffold */
    scaffoldBackgroundColor: backgroundColor,
    /* style mặc định cho TextField / TextFormField */
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB2BEC3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB2BEC3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
  const darkInputBorderColor = Colors.white; // Viền input

  return ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: Colors.black),
    cardTheme: CardThemeData(
      color: Colors.red[40]
    ),
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: darkPrimaryColor,
      surface: darkSurfaceColor,
      onSurface: darkTextColor, // ← Màu chữ & icon tự động sáng lên
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF2A1F3D),
    ),
    /* mau chu dao */
    primaryColor: darkPrimaryColor,
    /* mau nen scaffold */
    scaffoldBackgroundColor: darkBackgroundColor,
    /* style mặc định cho TextField / TextFormField */
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkPrimaryColor),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
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

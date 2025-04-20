import 'package:flutter/material.dart';

ThemeData lightTheme(){
  return ThemeData(
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6A5ACD),
      secondary: const Color(0xFFFF7F50),
      tertiary: const Color(0xFF20B2AA),
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    cardTheme: CardTheme(color: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      floatingLabelStyle: TextStyle(color: const Color(0xFF6A5ACD)),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6A5ACD),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent
    ),
    useMaterial3: true,
    primarySwatch: Colors.indigo,
  );
}

ThemeData darkTheme(){
  return ThemeData(
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF9370DB),
      secondary: const Color(0xFFFF8C69),
      tertiary: const Color(0xFF48D1CC),
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: Colors.black,
    cardTheme: CardTheme(color: const Color(0xFF121212)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF121212),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: const Color(0xFF9370DB)), // Dark primary color
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      floatingLabelStyle: TextStyle(color: const Color(0xFF9370DB)),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF9370DB),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent
    ),
  );
}
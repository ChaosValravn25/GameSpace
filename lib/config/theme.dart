import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF00B894);
  static const Color accent = Color(0xFFFFDCB6E);
  
  // Background Colors
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);
  
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFECF0F1);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB2BEC3);
  static const Color textLight = Color(0xFF2D3436);
  
  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF7675);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);
  
  // Rating Colors
  static const Color ratingGold = Color(0xFFFDCB6E);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.textLight,
        size: 24,
      ),
    );
  }
}
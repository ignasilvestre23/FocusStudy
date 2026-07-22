import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0D0F18);
  static const surface = Color(0xFF161927);
  static const surface2 = Color(0xFF1E2235);
  static const border = Color(0xFF2A2F4A);
  static const accent = Color(0xFF7C6AF7);
  static const accent2 = Color(0xFFF7C26A);
  static const accent3 = Color(0xFF6AF7B8);
  static const danger = Color(0xFFF76A6A);
  static const text = Color(0xFFE8EAF4);
  static const muted = Color(0xFF7880A4);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          secondary: AppColors.accent2,
          tertiary: AppColors.accent3,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSurface: AppColors.text,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          labelStyle: GoogleFonts.nunito(color: AppColors.muted),
          hintStyle: GoogleFonts.nunito(color: AppColors.muted),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();
    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        // ignore: deprecated_member_use
        background: AppColors.background,
        primary: AppColors.primary,
        onPrimary: AppColors.darkBrown,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.darkBrown,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.mutedBrown,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkBrown),
        titleTextStyle: TextStyle(
          color: AppColors.darkBrown,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

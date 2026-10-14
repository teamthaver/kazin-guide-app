import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KazinColors {
  static const Color primaryBlue = Color(0xFF2563EB);  
  static const Color primaryNavy = Color(0xFF0F172A);  
  static const Color secondaryTeal = Color(0xFF0D9488);  
  static const Color lightTeal = Color(0xFFE6F4F1);

  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardWhite = Colors.white;
  static const Color borderSubtle = Color(0xFFE2E8F0);

  static const Color greenAcceptedBg = Color(0xFFD1FAE5);
  static const Color greenAcceptedText = Color(0xFF047857);
  static const Color amberWarningBg = Color(0xFFFEF3C7);
  static const Color amberWarningText = Color(0xFFB45309);
  static const Color redDanger = Color(0xFFDC2626);
  static const Color redDangerBg = Color(0xFFFEE2E2);
  static const Color blueInfoBg = Color(0xFFEFF6FF);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
}

class KazinTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: KazinColors.scaffoldBg,
      primaryColor: KazinColors.primaryNavy,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: KazinColors.textPrimary,
        displayColor: KazinColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: KazinColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KazinColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KazinColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

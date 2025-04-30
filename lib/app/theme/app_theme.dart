import 'package:ecommerce_app/app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class AppTheme {
  // Colors based on Open Fashion UI Kit
  static const Color primaryColor = Color(0xFF202224);    // Almost black
  static const Color secondaryColor = Color(0xFFDD8560);  // Coral/Salmon
  static const Color neutralDark = Color(0xFF333333);     // Dark gray for text
  static const Color neutralMedium = Color(0xFF555555);   // Medium gray
  static const Color neutralLight = Color(0xFFDDDDDD);    // Light gray (fixed alpha value)
  static const Color backgroundColor = Color(0xFFFAFAFA); // Off-white background
  static const Color textColor = Color(0xFF202224);       // Near black text
  static const Color titleActiveColor = Color(0xFFA8715A);// Terracotta
  
  // Check if the locale or text direction is Arabic
  static bool get isArabic {
    // Check both locale and text direction since one might be set before the other
    final bool localeIsArabic = Get.locale?.languageCode == 'ar';
    final bool directionIsRtl = Get.find<ThemeService>().textDirection == TextDirection.rtl;
    return localeIsArabic || directionIsRtl;
  }
  
  // Light Theme with explicit language parameter to avoid dependency on Get.locale
  static ThemeData getLightTheme({bool forceArabic = false}) {
    final ThemeData base = ThemeData.light();
    final textTheme = _getTextTheme(base.textTheme, primaryColor, neutralDark, forceArabic: forceArabic);
    
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: _getTitleTextStyle(primaryColor, forceArabic: forceArabic),
      ),
      // Add colorScheme to ensure proper color application
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: titleActiveColor,
        surface: Colors.white,
        onSurface: primaryColor,
      ),
      // Add these to ensure consistent text colors across different widgets
      indicatorColor: primaryColor,
      dividerColor: neutralLight,
      hintColor: neutralMedium,
      // Rest of your theme remains the same
    );
  }
  
  // Dark Theme with explicit language parameter to avoid dependency on Get.locale
  static ThemeData getDarkTheme({bool forceArabic = false}) {
    // Define white with opacity 0.9
    final lightTextColor = Colors.white.withAlpha(230); // ~0.9 opacity
    final ThemeData base = ThemeData.dark();
    final textTheme = _getTextTheme(base.textTheme, lightTextColor, Colors.white70, forceArabic: forceArabic);
    
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: secondaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: _getTitleTextStyle(Colors.white, forceArabic: forceArabic),
      ),
      // Add colorScheme to ensure proper color application
      colorScheme: ColorScheme.dark(
        primary: secondaryColor,
        secondary: titleActiveColor,
        tertiary: Colors.white70,
        surface: const Color(0xFF1A1A1A),
        onSurface: lightTextColor,
      ),
      // Add these to ensure consistent text colors across different widgets
      indicatorColor: secondaryColor,
      dividerColor: const Color(0xFF333333),
      hintColor: Colors.white70,
      // Rest of your theme remains the same
    );
  }
  
  // For compatibility with existing code
  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();
  
  // Helper method to get the appropriate font style for title based on locale
  static TextStyle _getTitleTextStyle(Color color, {bool forceArabic = false}) {
    if (forceArabic || isArabic) {
      // Use a font that looks good for Arabic text
      return GoogleFonts.cairo(
        color: color, 
        fontSize: 16, 
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );
    } else {
      // Use Tenor Sans for English and other languages
      return GoogleFonts.tenorSans(
        color: color, 
        fontSize: 16, 
        fontWeight: FontWeight.w400,
        letterSpacing: 2.0,
      );
    }
  }
  
  // Helper method to generate text theme with appropriate font based on locale
  static TextTheme _getTextTheme(TextTheme base, Color primaryTextColor, Color secondaryTextColor, {bool forceArabic = false}) {
    if (forceArabic || isArabic) {
      // Use Cairo for Arabic - it's a clean, modern font with good Arabic support
      return TextTheme(
        displayLarge: GoogleFonts.cairo(
          textStyle: base.displayLarge, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.cairo(
          textStyle: base.displayMedium, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: GoogleFonts.cairo(
          textStyle: base.displaySmall, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.cairo(
          textStyle: base.headlineMedium, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.cairo(
          textStyle: base.titleLarge, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.cairo(
          textStyle: base.titleMedium, 
          color: primaryTextColor, 
          letterSpacing: 0.5, 
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.cairo(
          textStyle: base.bodyLarge, 
          color: secondaryTextColor, 
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.cairo(
          textStyle: base.bodyMedium, 
          color: secondaryTextColor, 
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.cairo(
          textStyle: base.labelLarge, 
          color: primaryTextColor, 
          fontSize: 14, 
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      // Use Tenor Sans for English and other languages
      return TextTheme(
        displayLarge: GoogleFonts.tenorSans(
          textStyle: base.displayLarge, 
          color: primaryTextColor, 
          letterSpacing: 2.0, 
          fontSize: 28
        ),
        displayMedium: GoogleFonts.tenorSans(
          textStyle: base.displayMedium, 
          color: primaryTextColor, 
          letterSpacing: 2.0, 
          fontSize: 24
        ),
        displaySmall: GoogleFonts.tenorSans(
          textStyle: base.displaySmall, 
          color: primaryTextColor, 
          letterSpacing: 1.5, 
          fontSize: 20
        ),
        headlineMedium: GoogleFonts.tenorSans(
          textStyle: base.headlineMedium, 
          color: primaryTextColor, 
          letterSpacing: 1.5, 
          fontSize: 18
        ),
        titleLarge: GoogleFonts.tenorSans(
          textStyle: base.titleLarge, 
          color: primaryTextColor, 
          letterSpacing: 1.5, 
          fontSize: 16
        ),
        titleMedium: GoogleFonts.tenorSans(
          textStyle: base.titleMedium, 
          color: primaryTextColor, 
          letterSpacing: 1.0, 
          fontSize: 15
        ),
        bodyLarge: GoogleFonts.tenorSans(
          textStyle: base.bodyLarge, 
          color: secondaryTextColor, 
          fontSize: 14
        ),
        bodyMedium: GoogleFonts.tenorSans(
          textStyle: base.bodyMedium, 
          color: secondaryTextColor, 
          fontSize: 13
        ),
        labelLarge: GoogleFonts.tenorSans(
          textStyle: base.labelLarge, 
          color: primaryTextColor, 
          fontSize: 14, 
          letterSpacing: 1.5
        ),
      );
    }
  }
}
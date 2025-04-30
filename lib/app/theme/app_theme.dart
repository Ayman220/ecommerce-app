import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  // Light Theme
  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light();
    final textTheme = _getTextTheme(base.textTheme, primaryColor, neutralDark);
    
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.tenorSans(
          color: primaryColor, 
          fontSize: 16, 
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
        ),
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
  
  // Dark Theme
  static ThemeData get darkTheme {
    // Define white with opacity 0.9
    final lightTextColor = Colors.white.withAlpha(230); // ~0.9 opacity
    final ThemeData base = ThemeData.dark();
    final textTheme = _getTextTheme(base.textTheme, lightTextColor, Colors.white70);
    
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: secondaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.tenorSans(
          color: Colors.white, 
          fontSize: 16, 
          fontWeight: FontWeight.w400,
          letterSpacing: 2.0,
        ),
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
  
  // Helper method to generate text theme with Tenor Sans font
  static TextTheme _getTextTheme(TextTheme base, Color primaryTextColor, Color secondaryTextColor) {
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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Open Fashion uses a minimalist color palette
  static const Color primaryColor = Color(0xFF333333);
  static const Color secondaryColor = Color(0xFFDD8560);
  static const Color backgroundColor = Color(0xFFFCFCFC);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB3261E);
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF555555);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFEAEAEA);
  static const Color placeholderColor = Color(0xFFBDBDBD);

  // Font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSize2XL = 20.0;
  static const double fontSize3XL = 24.0;
  static const double fontSize4XL = 30.0;
  static const double fontSize5XL = 36.0;
  
  // Border radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 16.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacing2XL = 40.0;
  static const double spacing3XL = 48.0;

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.tenorSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: fontSize5XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
            color: textPrimaryColor,
          ),
          displayMedium: TextStyle(
            fontSize: fontSize4XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
            color: textPrimaryColor,
          ),
          displaySmall: TextStyle(
            fontSize: fontSize3XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.2,
            color: textPrimaryColor,
          ),
          headlineLarge: TextStyle(
            fontSize: fontSize3XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            color: textPrimaryColor,
          ),
          headlineMedium: TextStyle(
            fontSize: fontSize2XL,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            color: textPrimaryColor,
          ),
          headlineSmall: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
            color: textPrimaryColor,
          ),
          titleLarge: TextStyle(
            fontSize: fontSizeXL,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
            color: textPrimaryColor,
          ),
          titleMedium: TextStyle(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: textPrimaryColor,
          ),
          titleSmall: TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: textPrimaryColor,
          ),
          bodyLarge: TextStyle(
            fontSize: fontSizeL,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: textPrimaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: textPrimaryColor,
          ),
          bodySmall: TextStyle(
            fontSize: fontSizeS,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: textSecondaryColor,
          ),
          labelLarge: TextStyle(
            fontSize: fontSizeM,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: textPrimaryColor,
          ),
          labelMedium: TextStyle(
            fontSize: fontSizeS,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: textPrimaryColor,
          ),
          labelSmall: TextStyle(
            fontSize: fontSizeXS,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: textSecondaryColor,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: TextStyle(
          fontSize: fontSizeL,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.0,
          color: textPrimaryColor,
        ),
        iconTheme: IconThemeData(
          color: textPrimaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusS),
          ),
          textStyle: const TextStyle(
            letterSpacing: 1.0,
            fontSize: fontSizeM,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusS),
          ),
          textStyle: const TextStyle(
            letterSpacing: 1.0,
            fontSize: fontSizeM,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            letterSpacing: 1.0,
            fontSize: fontSizeM,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusS),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusS),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusS),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusS),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: TextStyle(
          color: textSecondaryColor.withAlpha((0.5 * 255).toInt()),
          fontSize: fontSizeM,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingM,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: TextStyle(
          fontSize: fontSizeXS,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSizeXS,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        disabledColor: Colors.grey[200],
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          side: const BorderSide(color: borderColor),
        ),
        labelStyle: const TextStyle(
          fontSize: fontSizeS,
          color: textPrimaryColor,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: fontSizeS,
          color: Colors.white,
        ),
        brightness: Brightness.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: fontSizeM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusS),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
            return primaryColor;
            }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusS / 2),
        ),
        side: const BorderSide(color: borderColor, width: 1.5),
      ),
    );
  }
}
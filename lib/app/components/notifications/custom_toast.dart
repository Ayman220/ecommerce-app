import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

enum ToastType { success, error, info, warning }

class CustomToast {
  /// Shows a customized toast message
  static void show({
    required String message,
    ToastType type = ToastType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.TOP,
    bool useGetX = true,
  }) {
    if (useGetX) {
      _showGetXSnackbar(
        message: message,
        type: type,
        icon: icon,
        duration: duration,
      );
    } else {
      _showFlutterToast(
        message: message,
        type: type,
        duration: duration,
        gravity: gravity,
      );
    }
  }

  /// Shows success toast message
  static void success(String message, {IconData? icon, Duration? duration, bool useGetX = true}) {
    show(
      message: message,
      type: ToastType.success,
      icon: icon ?? Icons.check,
      duration: duration ?? const Duration(seconds: 3),
      useGetX: useGetX,
    );
  }

  /// Shows error toast message
  static void error(String message, {IconData? icon, Duration? duration, bool useGetX = true}) {
    show(
      message: message,
      type: ToastType.error,
      icon: icon ?? Icons.error_outline,
      duration: duration ?? const Duration(seconds: 3),
      useGetX: useGetX,
    );
  }

  /// Shows info toast message
  static void info(String message, {IconData? icon, Duration? duration, bool useGetX = true}) {
    show(
      message: message,
      type: ToastType.info,
      icon: icon ?? Icons.info_outline,
      duration: duration ?? const Duration(seconds: 3),
      useGetX: useGetX,
    );
  }

  /// Shows warning toast message
  static void warning(String message, {IconData? icon, Duration? duration, bool useGetX = true}) {
    show(
      message: message,
      type: ToastType.warning,
      icon: icon ?? Icons.warning_amber_outlined,
      duration: duration ?? const Duration(seconds: 3),
      useGetX: useGetX,
    );
  }

  /// Get color based on toast type and theme mode
  static Color _getColor(ToastType type) {
    final isDarkMode = Get.isDarkMode;
    
    switch (type) {
      case ToastType.success:
        return isDarkMode 
            ? const Color(0xFF4CAF50) // Brighter green for dark mode
            : const Color(0xFF4A8B71); // Elegant green for light mode
      case ToastType.error:
        return isDarkMode 
            ? const Color(0xFFF44336) // Brighter red for dark mode
            : const Color(0xFFB3261E); // Elegant red for light mode
      case ToastType.warning:
        return isDarkMode 
            ? const Color(0xFFFF9800) // Brighter orange for dark mode
            : const Color(0xFFDD8560); // Secondary color for light mode
      case ToastType.info:
        return isDarkMode 
            ? const Color(0xFF2196F3) // Blue for dark mode
            : const Color(0xFF333333); // Dark gray for light mode
    }
  }

  /// Get text color based on theme mode
  static Color _getTextColor() {
    return Colors.white; // Keep white text for all toast types for better contrast
  }

  /// Get icon based on toast type
  static IconData _getIcon(ToastType type, IconData? customIcon) {
    if (customIcon != null) return customIcon;
    
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  /// Show GetX snackbar with theme awareness
  static void _showGetXSnackbar({
    required String message,
    required ToastType type,
    IconData? icon,
    required Duration duration,
  }) {
    final textColor = _getTextColor();
    final backgroundColor = _getColor(type);
    final isDarkMode = Get.isDarkMode;
    
    // Adjust the opacity based on theme
    final alpha = isDarkMode ? (0.85 * 255).toInt() : (0.95 * 255).toInt();
    
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(
            _getIcon(type, icon),
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor.withAlpha(alpha),
      duration: duration,
      margin: EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: isDarkMode ? 16 : 12, // More margin in dark mode
      ),
      borderRadius: 6, // Slightly more rounded in both modes
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      padding: EdgeInsets.symmetric(
        horizontal: 16, 
        vertical: isDarkMode ? 14 : 12, // Slightly more padding in dark mode
      ),
      boxShadows: isDarkMode ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        )
      ],
      barBlur: 0,
    );
  }

  /// Show traditional Flutter toast with theme awareness
  static void _showFlutterToast({
    required String message,
    required ToastType type,
    required Duration duration,
    required ToastGravity gravity,
  }) {
    final textColor = _getTextColor();
    final backgroundColor = _getColor(type);
    
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
    );
  }
}
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

  /// Get color based on toast type
  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4A8B71); // Elegant green
      case ToastType.error:
        return const Color(0xFFB3261E); // Elegant red
      case ToastType.warning:
        return const Color(0xFFDD8560); // Secondary color
      case ToastType.info:
        return const Color(0xFF333333); // Primary color
    }
  }

  /// Get text color (always white for contrast)
  static const Color _textColor = Colors.white;

  /// Get icon based on toast type
  static IconData _getIcon(ToastType type, IconData? customIcon) {
    if (customIcon != null) return customIcon;
    
    switch (type) {
      case ToastType.success:
        return Icons.check;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  /// Show GetX snackbar (elegant, minimalist style)
  static void _showGetXSnackbar({
    required String message,
    required ToastType type,
    IconData? icon,
    required Duration duration,
  }) {
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(
            _getIcon(type, icon),
            color: _textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _textColor,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColor(type).withAlpha((0.95 * 255).toInt()),
      duration: duration,
      margin: const EdgeInsets.all(12),
      borderRadius: 4,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      barBlur: 0,
    );
  }

  /// Show traditional Flutter toast
  static void _showFlutterToast({
    required String message,
    required ToastType type,
    required Duration duration,
    required ToastGravity gravity,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity,
      timeInSecForIosWeb: duration.inSeconds,
      backgroundColor: _getColor(type),
      textColor: _textColor,
      fontSize: 14.0,
    );
  }
}
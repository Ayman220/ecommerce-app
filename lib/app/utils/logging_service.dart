import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, {Map<String, dynamic>? extras}) {
    _logger.d(message);
    _logExtras(extras);
  }

  static void info(String message, {Map<String, dynamic>? extras}) {
    _logger.i(message);
    _logExtras(extras);
  }

  static void warning(String message, {Map<String, dynamic>? extras}) {
    _logger.w(message);
    _logExtras(extras);

    if (kReleaseMode) {
      FirebaseCrashlytics.instance.log('WARNING: $message');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
    bool fatal = false,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _logExtras(extras);

    // Send to Crashlytics in release mode
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: fatal,
      );

      if (extras != null) {
        extras.forEach((key, value) {
          FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
        });
      }
    }
  }

  static void _logExtras(Map<String, dynamic>? extras) {
    if (extras != null && extras.isNotEmpty) {
      _logger.d('Extras: $extras');
    }
  }

  // Set user context for better error tracking
  static Future<void> setUserContext({
    required String userId,
    String? email,
    String? name,
  }) async {
    if (kReleaseMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      if (email != null) {
        await FirebaseCrashlytics.instance.setCustomKey('user_email', email);
      }
      if (name != null) {
        await FirebaseCrashlytics.instance.setCustomKey('user_name', name);
      }
    }
  }

  // Log custom events or breadcrumbs
  static void logEvent(String event, {Map<String, dynamic>? parameters}) {
    final msg = 'Event: $event${parameters != null ? ' - $parameters' : ''}';
    _logger.i(msg);

    if (kReleaseMode) {
      FirebaseCrashlytics.instance.log(msg);
    }
  }
}

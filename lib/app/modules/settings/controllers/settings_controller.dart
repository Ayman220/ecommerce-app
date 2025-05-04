import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/services/theme_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ThemeService _themeService = Get.find<ThemeService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxBool useSystemTheme = true.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxString currency = 'USD'.obs;
  final RxString languageCode = 'en'.obs;

  // User reference for storing settings
  User? get currentUser => _authService.currentUser;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    initializeLanguage();

    // Initialize theme values from ThemeService
    useSystemTheme.value = _themeService.useSystemTheme;
    isDarkMode.value = _themeService.isDarkMode;
  }

  Future<void> loadSettings() async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        isNotificationsEnabled.value = data['isNotificationsEnabled'] ?? true;
        currency.value = data['currency'] ?? 'USD';
        languageCode.value = data['languageCode'] ?? 'en';
      }
    } catch (e) {
      CustomToast.error('Failed to load settings');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .set({
        'isNotificationsEnabled': isNotificationsEnabled.value,
        'currency': currency.value,
        'languageCode': languageCode.value, // Store language code in Firestore
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      CustomToast.success('Settings saved successfully');
    } catch (e) {
      CustomToast.error('Failed to save settings');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    if (!useSystemTheme.value) {
      _themeService.toggleDarkMode(value);
    }
  }

  void toggleUseSystemTheme(bool value) {
    useSystemTheme.value = value;
    _themeService.setUseSystemTheme(value);
  }

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    saveSettings();
  }

  void setCurrency(String value) {
    currency.value = value;
    saveSettings();
  }

  void setLanguage(String code) {
    languageCode.value = code;

    // Apply the selected language to the app
    if (code == 'ar') {
      Get.updateLocale(const Locale('ar', 'SA'));
      // Enable RTL for Arabic
      Get.find<ThemeService>().updateTextDirection(TextDirection.rtl);
    } else {
      Get.updateLocale(const Locale('en', 'US'));
      // Use LTR for English
      Get.find<ThemeService>().updateTextDirection(TextDirection.ltr);
    }

    // Save to local storage through ThemeService (for persistence across app sessions)
    _themeService.saveLanguagePreference(code);

    // Save to Firestore (for cross-device sync)
    saveSettings();
  }

  void initializeLanguage() {
    // First check if we have a saved preference
    final String savedLanguageCode = _themeService.languagePreference;

    if (savedLanguageCode.isNotEmpty) {
      // Use saved preference
      languageCode.value = savedLanguageCode;
      if (savedLanguageCode == 'ar') {
        Get.updateLocale(const Locale('ar', 'SA'));
        Get.find<ThemeService>().updateTextDirection(TextDirection.rtl);
      } else {
        Get.updateLocale(const Locale('en', 'US'));
        Get.find<ThemeService>().updateTextDirection(TextDirection.ltr);
      }
    } else {
      // Fall back to system locale
      final String systemLocale = Get.deviceLocale?.languageCode ?? 'en';

      if (systemLocale == 'ar') {
        languageCode.value = 'ar';
        Get.updateLocale(const Locale('ar', 'SA'));
        Get.find<ThemeService>().updateTextDirection(TextDirection.rtl);
      } else {
        languageCode.value = 'en';
        Get.updateLocale(const Locale('en', 'US'));
        Get.find<ThemeService>().updateTextDirection(TextDirection.ltr);
      }
    }
  }

  // Add helper method to get display name from code
  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'ar':
        return 'arabic'.tr;
      case 'en':
      default:
        return 'english'.tr;
    }
  }
}

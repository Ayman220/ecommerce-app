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
  final RxString language = 'English'.obs;
  
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
        language.value = data['language'] ?? 'English';
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
            'language': language.value,
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
  
  void setLanguage(String lang) {
    language.value = lang;
    
    // Apply the selected language to the app
    if (lang == 'Arabic') {
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
    
    // Save the preference
    saveSettings();
  }
  
  void initializeLanguage() {
    // Get system locale
    final String systemLocale = Get.deviceLocale?.languageCode ?? 'en';
    
    // Set language based on system locale (only supporting English and Arabic)
    if (systemLocale == 'ar') {
      language.value = 'Arabic';
      // Set app locale to Arabic
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      // Default to English for any other language
      language.value = 'English';
      // Set app locale to English
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
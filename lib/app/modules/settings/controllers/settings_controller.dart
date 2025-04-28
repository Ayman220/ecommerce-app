import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool useSystemTheme = true.obs;
  final RxBool isNotificationsEnabled = true.obs;
  final RxString currency = 'USD'.obs;
  final RxString language = 'English'.obs;
  
  // User reference for storing settings
  User? get currentUser => _authService.currentUser;
  
  @override
  void onInit() {
    super.onInit();
    loadSettings();
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
        
        useSystemTheme.value = data['useSystemTheme'] ?? true;
        isDarkMode.value = data['isDarkMode'] ?? false;
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
            'useSystemTheme': useSystemTheme.value,
            'isDarkMode': isDarkMode.value,
            'isNotificationsEnabled': isNotificationsEnabled.value,
            'currency': currency.value,
            'language': language.value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      CustomToast.success('Settings saved successfully');
      
      // Apply theme changes
      _applyThemeChanges();
      
    } catch (e) {
      CustomToast.error('Failed to save settings');
    } finally {
      isLoading.value = false;
    }
  }
  
  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    if (!useSystemTheme.value) {
      saveSettings();
    }
  }
  
  void toggleUseSystemTheme(bool value) {
    useSystemTheme.value = value;
    saveSettings();
  }
  
  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
    saveSettings();
  }
  
  void setCurrency(String value) {
    currency.value = value;
    saveSettings();
  }
  
  void setLanguage(String value) {
    language.value = value;
    saveSettings();
  }
  
  void _applyThemeChanges() {
    // Implementation for theme changes would go here
    // This would connect to a theme service in a real app
  }
}
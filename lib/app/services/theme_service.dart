import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService extends GetxService {
  static const String themeModeKey = 'themeMode';
  static const String useSystemThemeKey = 'useSystemTheme';
  static const String themeBoxName = 'themeBox';

  late final Box<dynamic> _box;
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final RxBool _useSystemTheme = true.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get useSystemTheme => _useSystemTheme.value;
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  // Add the init method that was missing
  Future<ThemeService> init() async {
    _box = await Hive.openBox(themeBoxName);
    _loadThemeSettings();
    return this;
  }

  void _loadThemeSettings() {
    final useSystem = _box.get(useSystemThemeKey, defaultValue: true) as bool;
    _useSystemTheme.value = useSystem;

    if (useSystem) {
      _themeMode.value = ThemeMode.system;
    } else {
      final isDark = _box.get(themeModeKey, defaultValue: false) as bool;
      _themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    // Apply the theme
    Get.changeThemeMode(_themeMode.value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await _box.put(themeModeKey, mode == ThemeMode.dark);
    Get.changeThemeMode(mode);
  }

  Future<void> toggleDarkMode(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(mode);
  }

  Future<void> setUseSystemTheme(bool useSystem) async {
    _useSystemTheme.value = useSystem;
    await _box.put(useSystemThemeKey, useSystem);

    if (useSystem) {
      _themeMode.value = ThemeMode.system;
      Get.changeThemeMode(ThemeMode.system);
    } else {
      // If not using system theme, load saved theme or default to light
      final isDark = _box.get(themeModeKey, defaultValue: false) as bool;
      _themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(_themeMode.value);
    }
  }
}

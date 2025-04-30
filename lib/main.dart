import 'package:ecommerce_app/app/bindings/initial_binding.dart';
import 'package:ecommerce_app/app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerce_app/app/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize ThemeService after Hive is initialized
  await Get.putAsync(() => ThemeService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    // Get the saved language from ThemeService
    final String savedLanguage = themeService.languagePreference;
    
    // Determine which locale to use based on saved language
    Locale? initialLocale;
    if (savedLanguage.isNotEmpty) {
      if (savedLanguage == 'Arabic') {
        initialLocale = const Locale('ar', 'SA');
        // Pre-set text direction for Arabic to ensure proper initial rendering
        themeService.updateTextDirection(TextDirection.rtl);
      } else {
        initialLocale = const Locale('en', 'US');
        themeService.updateTextDirection(TextDirection.ltr);
      }
    }

    return GetMaterialApp(
      title: 'app_title'.tr,
      initialBinding: InitialBinding(),
      theme: themeService.getThemeData(isDark: false),
      darkTheme: themeService.getThemeData(isDark: true),
      themeMode: themeService.themeMode,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale ?? Get.deviceLocale, // Use saved locale if available, otherwise device locale
      fallbackLocale: const Locale('en', 'US'), // Default locale if the device locale isn't supported
      builder: (context, child) {
        // Wrap your app with a Directionality widget that uses the text direction from ThemeService
        return Directionality(
          textDirection: themeService.textDirection,
          child: child!,
        );
      },
      onInit: () {
        // Load language settings during app initialization
        if (savedLanguage.isNotEmpty) {
          themeService.loadLanguagePreference();
        }
      },
    );
  }
}

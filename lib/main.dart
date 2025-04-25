import 'package:ecommerce_app/app/bindings/initial_binding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/data/services/product_service.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:ecommerce_app/app/theme/app_theme.dart';
import 'package:ecommerce_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize global services
  // await initServices();
  
  runApp(const MyApp());
}

/// Initialize services before the app starts
Future<void> initServices() async {  
  // Auth service
  await Get.putAsync(() => AuthService().init());
  
  // Product service
  Get.put(ProductService());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Open Fashion',
      initialBinding: InitialBinding(),
      theme: AppTheme.lightTheme(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:get/get.dart';
import 'package:ecommerce_app/app/data/services/product_service.dart';
import 'package:ecommerce_app/app/modules/home/controllers/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize ProductService first
    Get.put<ProductService>(ProductService());
    
    // Then initialize HomeController (which depends on ProductService)
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
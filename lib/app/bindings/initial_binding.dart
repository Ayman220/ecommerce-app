import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/data/services/product_service.dart';
import 'package:ecommerce_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(AuthService(), permanent: true);
    Get.put(ProductService(), permanent: true);
    
    // Controllers
    Get.put(AuthController(), permanent: true);
    Get.put(CartController());
  }
}
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/product/controllers/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure CartController is available
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
    
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}
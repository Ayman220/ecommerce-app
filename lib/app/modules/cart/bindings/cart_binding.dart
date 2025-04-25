import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';

class CartBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(
      () => CartController(),
    );
  }
}
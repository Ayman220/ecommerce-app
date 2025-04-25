import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/checkout/controllers/checkout_controller.dart';

class CheckoutBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(
      () => CheckoutController(),
    );
  }
}
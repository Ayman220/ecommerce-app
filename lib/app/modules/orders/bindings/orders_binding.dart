import 'package:ecommerce_app/app/modules/orders/controllers/orders_controller.dart';
import 'package:get/get.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersController>(
      () => OrdersController(),
    );
  }
}
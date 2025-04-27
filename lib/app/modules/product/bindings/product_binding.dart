import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../modules/wishlist/controllers/wishlist_controller.dart';
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';

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
    
    // Add the WishlistController to be available in ProductDetailView
    if (!Get.isRegistered<WishlistController>()) {
      Get.lazyPut<WishlistController>(
        () => WishlistController(),
      );
    }
  }
}
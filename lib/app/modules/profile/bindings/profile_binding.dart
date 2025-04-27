import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure AuthService is registered
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }
    
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
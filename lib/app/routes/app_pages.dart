import 'package:get/get.dart';
import 'package:ecommerce_app/app/modules/auth/bindings/auth_binding.dart';
import 'package:ecommerce_app/app/modules/auth/views/login_view.dart';
import 'package:ecommerce_app/app/modules/auth/views/signup_view.dart';
import 'package:ecommerce_app/app/modules/home/bindings/home_binding.dart';
import 'package:ecommerce_app/app/modules/home/views/home_view.dart';
import 'package:ecommerce_app/app/modules/product/bindings/product_binding.dart';
import 'package:ecommerce_app/app/modules/product/views/product_detail_view.dart';
import 'package:ecommerce_app/app/modules/cart/bindings/cart_binding.dart';
import 'package:ecommerce_app/app/modules/cart/views/cart_view.dart';
import 'package:ecommerce_app/app/modules/checkout/bindings/checkout_binding.dart';
import 'package:ecommerce_app/app/modules/checkout/views/checkout_view.dart';
import 'package:ecommerce_app/app/modules/orders/bindings/orders_binding.dart';
import 'package:ecommerce_app/app/modules/orders/views/orders_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
  ];
}
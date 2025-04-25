import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/order_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  // Use put instead of find to ensure it exists
  late final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'all'.obs;

  // Stream subscription
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  @override
  void onInit() {
    super.onInit();

    // Make sure AuthService is available
    try {
      if (Get.isRegistered<AuthService>()) {
        _authService = Get.find<AuthService>();
      } else {
        _authService = Get.put(AuthService());
      }

      // Call loadOrders after ensuring dependencies are ready
      loadOrders();
    } catch (e) {
      isLoading.value = false;
      CustomToast.error('Failed to initialize. Please try again.');
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  void loadOrders() {
    try {
      final User? currentUser = _authService.currentUser;
      if (currentUser == null) {
        isLoading.value = false;
        CustomToast.error('Please sign in to view your orders');
        Get.offAllNamed(Routes.login);
        return;
      }

      isLoading.value = true;

      // Create a query based on the selected filter
      Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true);

      if (selectedFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedFilter.value);
      }

      // Listen for order changes
      _ordersSubscription = query.snapshots().listen((snapshot) {
        try {
          final loadedOrders = <OrderModel>[];

          for (var doc in snapshot.docs) {
            try {
              final orderModel = OrderModel.fromFirestore(doc);
              loadedOrders.add(orderModel);
            } catch (_) {
              // Continue with next document
            }
          }

          orders.value = loadedOrders;
        } catch (e) {
          CustomToast.error('Error processing your orders');
        } finally {
          isLoading.value = false;
        }
      }, onError: (e) {
        CustomToast.error('Failed to load orders');
        isLoading.value = false;
      });
    } catch (e) {
      CustomToast.error('Failed to load orders');
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      // Cancel existing subscription
      _ordersSubscription?.cancel();
      // Reload orders with new filter
      loadOrders();
    }
  }

  void viewOrderDetails(String orderId) {
    // This method is incomplete in your original code
    // For now, just show a toast
    CustomToast.info('Order details coming soon!');
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': Timestamp.now(),
      });

      CustomToast.success('Order cancelled successfully');
      return true;
    } catch (e) {
      CustomToast.error('Failed to cancel order');
      return false;
    }
  }
}

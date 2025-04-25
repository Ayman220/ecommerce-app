import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/cart_item_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  static CartController get to => Get.find<CartController>();
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Observables
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isProcessingCheckout = false.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble shipping = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final RxInt cartItemCount = 0.obs; // Number of unique items in cart
  final RxInt totalItemCount = 0.obs; // Sum of all item quantities
  
  // Stream subscription
  StreamSubscription<QuerySnapshot>? _cartSubscription;
  
  @override
  void onInit() {
    super.onInit();
    loadCart();
  }
  
  @override
  void onClose() {
    _cartSubscription?.cancel();
    super.onClose();
  }
  
  void loadCart() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      isLoading.value = false;
      _showAuthRequiredMessage();
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Listen for cart changes
      _cartSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .snapshots()
          .listen((snapshot) {
            final loadedItems = snapshot.docs
                .map((doc) => CartItemModel.fromFirestore(doc))
                .toList();
                
            cartItems.value = loadedItems;
            
            // Update unique item count for badge
            cartItemCount.value = loadedItems.length;
            
            // Calculate total quantity across all items
            totalItemCount.value = loadedItems.isEmpty ? 0 : loadedItems.fold(
              0, (accumulator, item) => accumulator + item.quantity);
            
            _calculateTotals();
            isLoading.value = false;
          }, onError: (e) {
            CustomToast.error('Failed to load cart items');
            isLoading.value = false;
          });
    } catch (e) {
      CustomToast.error('Failed to load cart items');
      isLoading.value = false;
    }
  }
  
  void _showAuthRequiredMessage() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign In Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please sign in to view your shopping bag and checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  
  void _calculateTotals() {
    // Calculate subtotal
    subtotal.value = cartItems.fold(
      0, 
      (totalSum, item) => totalSum + (item.price * item.quantity)
    );
    
    // Calculate shipping (example based on subtotal)
    if (subtotal.value > 100) {
      shipping.value = 0; // Free shipping for orders over $100
    } else if (subtotal.value > 0) {
      shipping.value = 10; // $10 shipping fee
    } else {
      shipping.value = 0; // No shipping fee for empty cart
    }
    
    // Calculate tax (example: 5% tax rate)
    tax.value = subtotal.value * 0.05;
    
    // Calculate total
    total.value = subtotal.value + shipping.value + tax.value;
  }
  
  void updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;
    
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(cartItemId)
          .update({
            'quantity': newQuantity,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      CustomToast.error('Failed to update quantity');
    }
  }
  
  Future<void> removeItem(String itemId) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(itemId)
          .delete();
          
      cartItemCount.value--;
      CustomToast.success('Item removed from cart');
    } catch (e) {
      CustomToast.error('Failed to remove item');
    }
  }
  
  void clearCart() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Clear Shopping Bag',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to remove all items from your shopping bag?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF333333),
                        side: const BorderSide(color: Color(0xFF333333)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          // Get all cart items
                          final cartDocs = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .collection('cart')
                              .get();
                              
                          // Create a batch to delete all items
                          final batch = FirebaseFirestore.instance.batch();
                          
                          for (final doc in cartDocs.docs) {
                            batch.delete(doc.reference);
                          }
                          
                          await batch.commit();
                          cartItemCount.value = 0;
                          CustomToast.success('Shopping bag cleared');
                        } catch (e) {
                          CustomToast.error('Failed to clear shopping bag');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'CLEAR',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void proceedToCheckout() {
    if (cartItems.isEmpty) {
      CustomToast.info('Your cart is empty');
      return;
    }
    
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showAuthRequiredMessage();
      return;
    }
    
    Get.toNamed(Routes.checkout);
  }
  
  void continueShopping() {
    Get.back();
  }

  Future<bool> addToCart(CartItemModel item) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showAuthRequiredMessage();
      return false;
    }
    
    try {
      // Check if item already exists in cart
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .where('productId', isEqualTo: item.productId)
          .where('size', isEqualTo: item.size)
          .where('color', isEqualTo: item.color)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        // Item exists, update quantity
        final existingItem = querySnapshot.docs.first;
        final currentQuantity = existingItem.data()['quantity'] as int;
        
        await existingItem.reference.update({
          'quantity': currentQuantity + item.quantity,
          'updatedAt': Timestamp.now(),
        });
        
        // Force an immediate local update
        final index = cartItems.indexWhere((element) => element.id == existingItem.id);
        if (index >= 0) {
          final updatedItem = cartItems[index].copyWith(
            quantity: currentQuantity + item.quantity
          );
          cartItems[index] = updatedItem;
          totalItemCount.value += item.quantity;
          _calculateTotals();
        }
      } else {
        // Add new item
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('cart')
            .doc(item.id)
            .set(item.toMap());
            
        // Force an immediate local update
        cartItems.add(item);
        cartItemCount.value = cartItems.length;
        totalItemCount.value += item.quantity;
        _calculateTotals();
      }
      
      return true;
    } catch (e) {
      CustomToast.error('Failed to add item to cart');
      return false;
    }
  }
}
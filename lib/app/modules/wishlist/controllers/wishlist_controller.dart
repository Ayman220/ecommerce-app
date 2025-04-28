import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/data/models/wishlist_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/routes/app_pages.dart';

class WishlistController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<WishlistItem> wishlistItems = <WishlistItem>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription? _wishlistSubscription;
  
  @override
  void onInit() {
    super.onInit();
    setupWishlistListener();
  }
  
  @override
  void onClose() {
    _wishlistSubscription?.cancel();
    super.onClose();
  }
  
  void setupWishlistListener() {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      isLoading.value = false;
      _showAuthRequiredMessage();
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Set up real-time listener for wishlist changes
      _wishlistSubscription = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            final List<WishlistItem> items = snapshot.docs
                .map((doc) => WishlistItem.fromFirestore(doc))
                .toList();
            
            wishlistItems.value = items;
            isLoading.value = false;
          }, onError: (error) {
            CustomToast.error('Error loading wishlist: ${error.toString()}');
            isLoading.value = false;
          });
    } catch (e) {
      CustomToast.error('Failed to set up wishlist listener: ${e.toString()}');
      isLoading.value = false;
    }
  }
  
  Future<void> addToWishlist(String productId, Map<String, dynamic> productData) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showAuthRequiredMessage();
      return;
    }
    
    try {
      // Check if product is already in wishlist
      final docRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productId);
          
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        CustomToast.info('Product is already in your wishlist');
        return;
      }
      
      // Add product to wishlist
      await docRef.set({
        'productId': productId,
        'name': productData['name'] ?? '',
        'imageUrl': productData['images']?[0] ?? '',
        'price': productData['price'] ?? 0.0,
        'discountedPrice': productData['discountedPrice'],
        'isAvailable': productData['isAvailable'] ?? true,
        'addedAt': FieldValue.serverTimestamp(),
      });
      
      CustomToast.success('Product added to wishlist');
    } catch (e) {
      CustomToast.error('Failed to add to wishlist: ${e.toString()}');
    }
  }
  
  Future<bool> isProductInWishlist(String productId) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productId)
          .get();
          
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> removeFromWishlist(String itemId) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(itemId)
          .delete();
          
      CustomToast.success('Item removed from wishlist');
    } catch (e) {
      CustomToast.error('Failed to remove item: ${e.toString()}');
    }
  }
  
  Future<void> toggleWishlistStatus(String productId, Map<String, dynamic> productData) async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showAuthRequiredMessage();
      return;
    }
    
    try {
      final docRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productId);
          
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Remove from wishlist
        await docRef.delete();
      } else {
        // Add to wishlist
        await docRef.set({
          'productId': productId,
          'name': productData['name'] ?? '',
          'imageUrl': productData['images']?[0] ?? '',
          'price': productData['price'] ?? 0.0,
          'discountedPrice': productData['discountedPrice'],
          'isAvailable': productData['isAvailable'] ?? true,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      CustomToast.error('Failed to update wishlist: ${e.toString()}');
    }
  }
  
  void goToProductDetail(String productId) {
    Get.toNamed(Routes.productDetail, arguments: productId);
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
                  'Please sign in to view your wishlist.',
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
}
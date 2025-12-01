import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/cart_item_model.dart';
import 'package:ecommerce_app/app/data/models/product_model.dart';
import 'package:ecommerce_app/app/data/models/review_model.dart';
import 'package:ecommerce_app/app/data/services/auth_service.dart';
import 'package:ecommerce_app/app/data/services/product_service.dart';
import 'package:ecommerce_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:ecommerce_app/app/utils/logging_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final AuthService _authService = Get.find<AuthService>();
  late CartController cartController;

  // Observables
  final Rx<ProductModel?> product = Rx<ProductModel?>(null);
  final RxList<ProductModel> relatedProducts = <ProductModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxInt selectedImageIndex = 0.obs;
  final RxInt quantity = 1.obs;
  final RxBool isLoading = true.obs;
  final RxBool isAddingToCart = false.obs;
  final RxBool isFavorite = false.obs;
  final RxString selectedSize = ''.obs;
  final RxString selectedColor = ''.obs;

  // Review-related properties
  final TextEditingController reviewTextController = TextEditingController();
  final RxDouble reviewRating = 0.0.obs;
  final RxBool canReview = false.obs;
  final RxBool isSubmittingReview = false.obs;
  final RxBool hasReviewed = false.obs;

  // Controllers
  final PageController pageController = PageController();

  // Current product ID
  String? productId;

  @override
  void onInit() {
    super.onInit();
    // Find or create CartController instance
    if (!Get.isRegistered<CartController>()) {
      Get.lazyPut(() => CartController());
    }
    cartController = Get.find<CartController>();

    productId = Get.arguments as String?;
    if (productId != null) {
      _loadProduct();
    } else {
      CustomToast.error('Product not found');
      Get.back();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    reviewTextController.dispose(); // Dispose of the text controller
    super.onClose();
  }

  void _loadProduct() async {
    try {
      isLoading.value = true;

      // Load product details
      final productData = await _productService.getProductById(productId!);
      if (productData == null) {
        CustomToast.error('Product not found');
        Get.back();
        return;
      }

      ProductModel productModel = productData;
      String categoryName = 'Uncategorized';
      try {
        final categorySnapshot = await FirebaseFirestore.instance
            .collection('categories')
            .doc(productData.categoryId)
            .get();

        if (categorySnapshot.exists && categorySnapshot.data() != null) {
          categoryName = categorySnapshot.data()!['name'] ?? 'Uncategorized';
        }
      } catch (_) {}
      product.value = productModel.copyWith(categoryName: categoryName);
      // Set default size and color if available
      if (productData.specifications != null) {
        if (productData.specifications!['sizes'] is List &&
            (productData.specifications!['sizes'] as List).isNotEmpty) {
          selectedSize.value =
              (productData.specifications!['sizes'] as List).first.toString();
        }

        if (productData.specifications!['colors'] is List &&
            (productData.specifications!['colors'] as List).isNotEmpty) {
          selectedColor.value =
              (productData.specifications!['colors'] as List).first.toString();
        }
      }

      // Load related products
      final related = await _productService.getRelatedProducts(
          productId!, productData.categoryId);
      relatedProducts.value = related;

      // Add to recently viewed if user is logged in
      final User? currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _productService.addToRecentlyViewed(currentUser.uid, productId!);

        // Check if product is in favorites
        _checkIfFavorite(currentUser.uid);
      }

      // Load reviews
      _loadReviews();

      // Check review eligibility
      await checkReviewEligibility();
    } catch (_) {
      CustomToast.error('Error loading product');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadReviews() async {
    try {
      final reviewsData = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      reviews.value = reviewsData.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to load reviews',
        error: e,
        stackTrace: stackTrace,
        extras: {
          'productId': productId,
        },
      );
      CustomToast.error('Error loading reviews');
    }
  }

  void _checkIfFavorite(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .get();

      isFavorite.value = doc.exists;
    } catch (_) {
      CustomToast.error('Error checking if product is favorite');
    }
  }

  void changeImage(int index) {
    if (index >= 0 && index < (product.value?.imageUrls.length ?? 0)) {
      selectedImageIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void incrementQuantity() {
    if (quantity.value < (product.value?.stock ?? 1)) {
      quantity.value++;
    } else {
      CustomToast.info('Maximum available quantity reached');
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void selectColor(String color) {
    selectedColor.value = color;
  }

  Future<void> toggleFavorite() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      CustomToast.info('Please sign in to add products to favorites');
      return;
    }

    try {
      final favRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(productId);

      if (isFavorite.value) {
        // Remove from favorites
        await favRef.delete();
        isFavorite.value = false;
        CustomToast.success('Removed from favorites');
      } else {
        // Add to favorites
        await favRef.set({
          'productId': productId,
          'addedAt': Timestamp.now(),
        });
        isFavorite.value = true;
        CustomToast.success('Added to favorites');
      }
    } catch (e) {
      CustomToast.error('Failed to update favorites');
    }
  }

  bool get needsColor {
    return product.value?.specifications?['colors'] != null &&
        (product.value!.specifications!['colors'] as List).isNotEmpty;
  }

  Future<void> addToCart() async {
    if (!product.value!.isInStock) return;

    // Validate size/color if required
    if (product.value?.specifications?['sizes'] != null &&
        selectedSize.value.isEmpty) {
      CustomToast.warning('Please select a size before adding to cart');
      return;
    }

    if (needsColor && selectedColor.value.isEmpty) {
      CustomToast.warning('Please select a color before adding to cart');
      return;
    }

    isAddingToCart.value = true;

    try {
      // Use the already found controller instead of trying to find it again
      final CartItemModel cartItem = CartItemModel(
        id: const Uuid().v4(),
        productId: product.value!.id,
        name: product.value!.name,
        price: product.value!.currentPrice,
        image: product.value!.imageUrls.isNotEmpty
            ? product.value!.imageUrls[0]
            : '',
        quantity: quantity.value,
        size: selectedSize.value.isNotEmpty ? selectedSize.value : null,
        color: selectedColor.value.isNotEmpty ? selectedColor.value : null,
        addedAt: DateTime.now(),
      );

      final success = await cartController.addToCart(cartItem);

      if (success) {
        // Force cart to refresh from Firestore
        cartController.loadCart();

        CustomToast.success('Product added to cart');
      }
    } catch (_) {
      CustomToast.error('Could not add product to cart');
    } finally {
      isAddingToCart.value = false;
    }
  }

  void buyNow() {
    addToCart().whenComplete(() {
      Get.toNamed('/cart');
    });
  }

  void refreshProduct() {
    _loadProduct();
  }

  Future<void> checkReviewEligibility() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      canReview.value = false;
      return;
    }

    try {
      // Check if the user has already reviewed this product
      final existingReview = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      hasReviewed.value = existingReview.docs.isNotEmpty;

      if (hasReviewed.value) {
        canReview.value = false;
        return;
      }

      // Check if the user has purchased this product
      final purchaseHistory = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', whereIn: ['delivered', 'completed']).get();

      bool hasPurchased = false;

      for (var order in purchaseHistory.docs) {
        final items = order.data()['items'] as List<dynamic>;
        if (items.any((item) => item['productId'] == productId)) {
          hasPurchased = true;
          break;
        }
      }

      canReview.value = hasPurchased;
    } catch (e) {
      canReview.value = false;
    }
  }

  Future<void> submitReview() async {
    final User? currentUser = _authService.currentUser;
    if (currentUser == null) {
      CustomToast.error('Please sign in to submit a review');
      return;
    }

    if (reviewRating.value == 0) {
      CustomToast.warning('Please select a rating before submitting');
      return;
    }

    if (reviewTextController.text.trim().isEmpty) {
      CustomToast.warning('Please enter your review text');
      return;
    }

    try {
      isSubmittingReview.value = true;

      // Create the review document
      final reviewId = const Uuid().v4();
      final reviewRef = FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId);

      // Get user information for the review
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String userName = 'Anonymous';
      String? userAvatar;

      if (userDoc.exists) {
        userName =
            userDoc.data()?['name'] ?? currentUser.displayName ?? 'Anonymous';
        userAvatar = userDoc.data()?['photoURL'] ?? currentUser.photoURL;
      }

      // Create the review
      final review = ReviewModel(
        id: reviewId,
        userId: currentUser.uid,
        userName: userName,
        userAvatar: userAvatar,
        rating: reviewRating.value,
        text: reviewTextController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await reviewRef.set(review.toMap());

      // Update product rating
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);

      // Get all reviews to calculate new average
      final allReviews = await productRef.collection('reviews').get();

      double totalRating = 0;
      for (var doc in allReviews.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      double newAvgRating = totalRating / allReviews.docs.length;
      int newReviewCount = allReviews.docs.length;

      // Update product with new rating and review count
      await productRef.update({
        'rating': newAvgRating,
        'reviewCount': newReviewCount,
      });

      // Update local product model
      if (product.value != null) {
        product.value = product.value!.copyWith(
          rating: newAvgRating,
          reviewCount: newReviewCount,
        );
      }

      // Refresh reviews
      _loadReviews();

      // Reset review form
      reviewTextController.clear();
      reviewRating.value = 0;

      // Update review eligibility
      hasReviewed.value = true;
      canReview.value = false;

      CustomToast.success('Your review has been submitted');
    } catch (e) {
      CustomToast.error('Failed to submit review');
    } finally {
      isSubmittingReview.value = false;
    }
  }
}

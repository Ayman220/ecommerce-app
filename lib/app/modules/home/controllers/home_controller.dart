import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/app/data/models/category_model.dart';
import 'package:ecommerce_app/app/data/models/product_model.dart';
import 'package:ecommerce_app/app/data/services/product_service.dart';
import 'package:ecommerce_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final AuthController _authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  
  // State management
  final RxBool isLoading = true.obs;
  final RxBool isSearching = false.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  // Stream subscriptions
  StreamSubscription<List<CategoryModel>>? _categoriesSubscription;
  StreamSubscription<List<ProductModel>>? _featuredProductsSubscription;
  StreamSubscription<List<ProductModel>>? _newArrivalsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initStreams();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _disposeStreams();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _initStreams() {
    isLoading.value = true;
    
    // Get all categories
    _categoriesSubscription = _productService.getAllCategories().listen(
      (data) {
        categories.value = data;
        isLoading.value = false;
      },
      onError: (error) {
        CustomToast.error('Error loading categories: $error');
        isLoading.value = false;
      },
    );

    // Get featured products
    _featuredProductsSubscription = _productService.getFeaturedProducts().listen(
      (data) {
        featuredProducts.value = data;
      },
      onError: (error) {
        CustomToast.error('Error loading featured products: $error');
      },
    );

    // Get new arrivals (products sorted by date)
    _newArrivalsSubscription = _productService.getAllProducts().listen(
      (data) {
        // Sort by createdAt - newest first
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        newArrivals.value = data.take(10).toList();
      },
      onError: (error) {
        CustomToast.error('Error loading new arrivals: $error');
      },
    );
  }

  void _disposeStreams() {
    _categoriesSubscription?.cancel();
    _featuredProductsSubscription?.cancel();
    _newArrivalsSubscription?.cancel();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    if (searchController.text.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
    } else {
      isSearching.value = true;
      _performSearch();
    }
  }

  void _performSearch() {
    if (searchQuery.value.length < 2) return;

    _productService.searchProducts(searchQuery.value).listen(
      (results) {
        searchResults.value = results;
      },
      onError: (error) {
        CustomToast.error('Error searching products: $error');
      },
    );
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch products as you normally do
      final snapshot = await _firestore.collection('products').get();
      final products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      
      // Fetch all categories to get their names
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final categoriesMap = <String, String>{};
      for (var doc in categoriesSnapshot.docs) {
        categoriesMap[doc.id] = doc.data()['name'] ?? 'Uncategorized';
      }
      
      // Update each product with its category name
      for (var product in products) {
        if (categoriesMap.containsKey(product.categoryId)) {
          product.updateCategoryName(categoriesMap[product.categoryId] ?? 'Uncategorized');
        }
      }
      
      // Update your lists
      featuredProducts.value = products.where((p) => p.isFeatured).toList();
      newArrivals.value = products.take(6).toList();
      
    } catch (e) {
      CustomToast.error('Error fetching products');
    }
  }

  void selectCategory(int index) {
    if (selectedCategoryIndex.value == index) return;
    selectedCategoryIndex.value = index;
    // You could load products by category here
  }

  void clearSearch() {
    searchController.clear();
    isSearching.value = false;
    searchResults.clear();
  }

  void logout() {
    _authController.signOut();
  }

  void refreshData() {
    isLoading.value = true;
    _disposeStreams();
    _initStreams();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<ProductService>(() => ProductService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
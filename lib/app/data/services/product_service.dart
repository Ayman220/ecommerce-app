import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/components/notifications/custom_toast.dart';
import 'package:ecommerce_app/app/data/models/category_model.dart';
import 'package:ecommerce_app/app/data/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get all categories
  Stream<List<CategoryModel>> getAllCategories() {
    return _firestore
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromFirestore(doc))
            .toList());
  }
  
  // Get featured products
  Stream<List<ProductModel>> getFeaturedProducts() {
    return _firestore.collection('products')
      .where('isFeatured', isEqualTo: true)
      .snapshots()
      .asyncMap((snapshot) async {
        final products = snapshot.docs.map((doc) => 
          ProductModel.fromMap(doc.data(), doc.id)).toList();
        
        // Fetch all categories
        final categoriesSnapshot = await _firestore.collection('categories').get();
        final Map<String, String> categoryMap = {};
        
        for (var cat in categoriesSnapshot.docs) {
          categoryMap[cat.id] = cat.data()['name'] ?? 'Uncategorized';
        }
        
        // Update each product with its category name
        for (var product in products) {
          if (product.categoryId.isNotEmpty && categoryMap.containsKey(product.categoryId)) {
            product.updateCategoryName(categoryMap[product.categoryId] ?? 'Uncategorized');
          }
        }
        
        return products;
      });
  }
  
  // Get all products
  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().asyncMap((snapshot) async {
      final products = snapshot.docs.map((doc) => 
        ProductModel.fromMap(doc.data(), doc.id)).toList();
      
      // Fetch all categories
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final Map<String, String> categoryMap = {};
      
      for (var cat in categoriesSnapshot.docs) {
        categoryMap[cat.id] = cat.data()['name'] ?? 'Uncategorized';
      }
      
      // Update each product with its category name
      for (var product in products) {
        if (product.categoryId.isNotEmpty && categoryMap.containsKey(product.categoryId)) {
          product.updateCategoryName(categoryMap[product.categoryId] ?? 'Uncategorized');
        }
      }
      
      return products;
    });
  }
  
  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .asyncMap((snapshot) async {
          final products = snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
          
          // Fetch category name
          final categoryDoc = await _firestore.collection('categories').doc(categoryId).get();
          final categoryName = (categoryDoc.data() ?? {})['name'] ?? 'Uncategorized';
          
          // Update each product with its category name
          for (var product in products) {
            product.updateCategoryName(categoryName);
          }
          
          return products;
        });
  }
  
  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }
  
  // Search products
  Stream<List<ProductModel>> searchProducts(String query) {
    // Convert query to lowercase for case-insensitive search
    final searchTerms = query.toLowerCase().split(' ')
      .where((term) => term.isNotEmpty)
      .toList();
      
    if (searchTerms.isEmpty) {
      return Stream.value([]);
    }
    
    // For simple search, we'll search in name and description fields
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc))
              .where((product) {
                final name = product.name.toLowerCase();
                final description = product.description.toLowerCase();
                
                // Check if any search term is in the name or description
                return searchTerms.any((term) => 
                    name.contains(term) || description.contains(term));
              })
              .toList();
        });
  }
  
  // Get related products
  Future<List<ProductModel>> getRelatedProducts(String currentProductId, String categoryId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where(FieldPath.documentId, isNotEqualTo: currentProductId)
        .limit(10)
        .get();
        
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }
  
  // Add to recently viewed
  Future<void> addToRecentlyViewed(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recentlyViewed')
          .doc(productId)
          .set({
            'productId': productId,
            'viewedAt': Timestamp.now(),
          });
    } catch (e) {
      CustomToast.error('Error adding to recently viewed');
    }
  }
  
  // Get recently viewed products
  Future<List<ProductModel>> getRecentlyViewedProducts() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    
    try {
      final recentlyViewedDocs = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recentlyViewed')
          .orderBy('viewedAt', descending: true)
          .limit(10)
          .get();
          
      if (recentlyViewedDocs.docs.isEmpty) return [];
      
      // Get product IDs
      final productIds = recentlyViewedDocs.docs
          .map((doc) => doc.data()['productId'] as String)
          .toList();
          
      // Fetch products
      final products = <ProductModel>[];
      for (final id in productIds) {
        final product = await getProductById(id);
        if (product != null) {
          products.add(product);
        }
      }
      
      return products;
    } catch (_) {
      return [];
    }
  }
}
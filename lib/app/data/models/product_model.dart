import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double currentPrice;
  final List<String> imageUrls;
  final String categoryId;
  String categoryName = 'Uncategorized'; // Default value
  final Map<String, dynamic>? specifications;
  final bool isFeatured;
  final bool isOnSale;
  final double? discountPercentage;
  final int stock;
  final bool isInStock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currentPrice,
    required this.imageUrls,
    required this.categoryId,
    this.categoryName = 'Uncategorized',
    this.specifications,
    required this.isFeatured,
    required this.isOnSale,
    this.discountPercentage,
    required this.stock,
    required this.isInStock,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  void updateCategoryName(String name) {
    categoryName = name;
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(), // Convert to double
      currentPrice:
          (data['compareAtPrice'] ?? 0).toDouble(), // Convert to double
      imageUrls: (data['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? 'Uncategorized',
      specifications: data['specifications'],
      isFeatured: data['isFeatured'] ?? false,
      isOnSale: data['isOnSale'] ?? false,
      discountPercentage: (data['price'] ?? 0.0) > 0
          ? (((data['price'] ?? 0.0) -
                      (data['compareAtPrice'] ?? data['price'] ?? 0.0)) /
                  (data['price'] ?? 0.0)) *
              100
          : null,
      stock: (data['stock'] ?? 0).toInt(), // Convert to int if needed
      isInStock: (data['stock'] ?? 0) > 0,
      rating: (data['rating'] ?? 0).toDouble(), // Convert to double
      reviewCount:
          (data['reviewCount'] ?? 0).toInt(), // Convert to int if needed
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currentPrice: (map['compareAtPrice'] ?? map['price'] ?? 0).toDouble(),
      imageUrls: (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? 'Uncategorized',
      specifications: map['specifications'],
      isFeatured: map['isFeatured'] ?? false,
      isOnSale: map['isOnSale'] ?? false,
      discountPercentage: (map['price'] ?? 0.0) > 0
          ? (((map['price'] ?? 0.0) -
                      (map['compareAtPrice'] ?? map['price'] ?? 0.0)) /
                  (map['price'] ?? 0.0)) *
              100
          : null,
      stock: (map['stock'] ?? 0).toInt(), // Convert to int if needed
      isInStock: (map['stock'] ?? 0) > 0,
      rating: (map['rating'] ?? 0).toDouble(), // Convert to double
      reviewCount:
          (map['reviewCount'] ?? 0).toInt(), // Convert to int if needed
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'currentPrice': currentPrice,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'specifications': specifications,
      'isFeatured': isFeatured,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Add copyWith method to allow creating a new instance with modified properties
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? currentPrice,
    List<String>? imageUrls,
    String? categoryId,
    String? categoryName,
    Map<String, dynamic>? specifications,
    bool? isFeatured,
    bool? isOnSale,
    double? discountPercentage,
    int? stock,
    bool? isInStock,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currentPrice: currentPrice ?? this.currentPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      specifications: specifications ?? this.specifications,
      isFeatured: isFeatured ?? this.isFeatured,
      isOnSale: isOnSale ?? this.isOnSale,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      stock: stock ?? this.stock,
      isInStock: isInStock ?? this.isInStock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

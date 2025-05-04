import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final double? discountedPrice;
  final bool isAvailable;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discountedPrice,
    this.isAvailable = true,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discountedPrice': discountedPrice,
      'isAvailable': isAvailable,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'discountedPrice': discountedPrice,
      'isAvailable': isAvailable,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory WishlistItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle date conversion safely
    DateTime dateTime;
    try {
      dateTime = data['addedAt'] is Timestamp 
          ? (data['addedAt'] as Timestamp).toDate() 
          : DateTime.now();
    } catch (e) {
      dateTime = DateTime.now();
    }
    
    return WishlistItem(
      id: doc.id,
      productId: data['productId'] ?? doc.id,
      name: data['name'] ?? 'Unknown Product',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      discountedPrice: (data['discountedPrice'] is num) 
          ? (data['discountedPrice'] as num).toDouble() 
          : null,
      isAvailable: data['isAvailable'] ?? true,
      addedAt: dateTime,
    );
  }
}
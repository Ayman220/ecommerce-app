import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String? size;
  final String? color;
  final DateTime addedAt;
  
  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    this.size,
    this.color,
    required this.addedAt,
  });
  
  double get totalPrice => price * quantity;
  
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] ?? 0.0) is int 
          ? (data['price'] ?? 0.0).toDouble()
          : (data['price'] ?? 0.0),
      image: data['image'] ?? '',
      quantity: data['quantity'] ?? 1,
      size: data['size'],
      color: data['color'],
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
      'size': size,
      'color': color,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
  
  // Add copyWith method to create a new instance with updated properties
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    double? price,
    String? image,
    int? quantity,
    String? size,
    String? color,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      color: color ?? this.color,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
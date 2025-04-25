import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/app/data/models/address_model.dart';
import 'package:ecommerce_app/app/data/models/cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final AddressModel shippingAddress;
  final String paymentMethod;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse items
    final List<CartItemModel> orderItems = [];
    if (data['items'] != null) {
      for (var item in data['items']) {
        orderItems.add(CartItemModel(
          id: item['id'],
          productId: item['productId'],
          name: item['name'],
          price: item['price'] is int ? (item['price'] as int).toDouble() : item['price'],
          image: item['image'],
          quantity: item['quantity'],
          size: item['size'],
          color: item['color'],
          addedAt: (item['addedAt'] as Timestamp).toDate(),
        ));
      }
    }
    
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: orderItems,
      shippingAddress: AddressModel.fromMap(data['shippingAddress']),
      paymentMethod: data['paymentMethod'] ?? 'unknown',
      subtotal: data['subtotal'] is int ? (data['subtotal'] as int).toDouble() : data['subtotal'] ?? 0.0,
      shipping: data['shipping'] is int ? (data['shipping'] as int).toDouble() : data['shipping'] ?? 0.0,
      tax: data['tax'] is int ? (data['tax'] as int).toDouble() : data['tax'] ?? 0.0,
      total: data['total'] is int ? (data['total'] as int).toDouble() : data['total'] ?? 0.0,
      status: data['status'] ?? 'pending',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    final itemsMap = items.map((item) => {
      'id': item.id,
      'productId': item.productId,
      'name': item.name,
      'price': item.price,
      'image': item.image,
      'quantity': item.quantity,
      'size': item.size,
      'color': item.color,
      'addedAt': Timestamp.fromDate(item.addedAt),
    }).toList();
    
    return {
      'id': id,
      'userId': userId,
      'items': itemsMap,
      'shippingAddress': shippingAddress.toMap(),
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': status,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  String getFormattedDate() {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  String getStatusLabel() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Placed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    AddressModel? shippingAddress,
    String? paymentMethod,
    double? subtotal,
    double? shipping,
    double? tax,
    double? total,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? description;
  final int order;
  final bool isActive;
  
  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    required this.order,
    required this.isActive,
  });
  
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Category',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'],
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'order': order,
      'isActive': isActive,
    };
  }
}
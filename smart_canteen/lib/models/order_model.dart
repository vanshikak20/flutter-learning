import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String itemId;
  final String name;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  // converts to a plain map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  // converts Firestore map back into an OrderItemModel
  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final int tokenNumber;
  final String studentId;
  final String studentName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status;
  final int estimatedWaitMinutes;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.tokenNumber,
    required this.studentId,
    required this.studentName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.estimatedWaitMinutes,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      tokenNumber: data['tokenNumber'] ?? 0,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      items: (data['items'] as List<dynamic>)
          .map((item) => OrderItemModel.fromMap(item))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      estimatedWaitMinutes: data['estimatedWaitMinutes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
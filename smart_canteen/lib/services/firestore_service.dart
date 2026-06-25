import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // fetch all available menu items once
  Future<List<MenuItemModel>> getMenuItems() async {
  final snapshot = await _firestore
      .collection('menuItems')
      .where('isAvailable', isEqualTo: true)
      .get();

  print('Total docs fetched: ${snapshot.docs.length}');

  return snapshot.docs.map((doc) {
    print('Doc: ${doc.data()}');
    return MenuItemModel.fromFirestore(doc.data(), doc.id);
  }).toList();
}
  // get all menu items for employee (including unavailable ones)
Stream<List<MenuItemModel>> getMenuItemsStream() {
  return _firestore
      .collection('menuItems')
      .orderBy('category')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MenuItemModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
}
// stream all orders for a specific student
Stream<List<OrderModel>> getStudentOrdersStream(String studentId) {
  return _firestore
      .collection('orders')
      .where('studentId', isEqualTo: studentId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return OrderModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
}
Future<Map<String, dynamic>?> getUserData(String uid) async {
  final doc = await _firestore.collection('users').doc(uid).get();
  return doc.data();
}

// add a new menu item
Future<void> addMenuItem(MenuItemModel item) async {
  await _firestore.collection('menuItems').add({
    'name': item.name,
    'description': item.description,
    'price': item.price,
    'category': item.category,
    'imageUrl': item.imageUrl,
    'isAvailable': item.isAvailable,
    'prepTimeMinutes': item.prepTimeMinutes,
  });
}

// update existing menu item
Future<void> updateMenuItem(MenuItemModel item) async {
  await _firestore.collection('menuItems').doc(item.id).update({
    'name': item.name,
    'description': item.description,
    'price': item.price,
    'category': item.category,
    'imageUrl': item.imageUrl,
    'isAvailable': item.isAvailable,
    'prepTimeMinutes': item.prepTimeMinutes,
  });
}

// toggle availability only
Future<void> toggleMenuItemAvailability(
  String itemId,
  bool currentValue,
) async {
  await _firestore.collection('menuItems').doc(itemId).update({
    'isAvailable': !currentValue,
  });
}

// delete a menu item
Future<void> deleteMenuItem(String itemId) async {
  await _firestore.collection('menuItems').doc(itemId).delete();
}
  // stream of ALL active orders for employee
// excludes completed orders
Stream<List<OrderModel>> getActiveOrdersStream() {
  return _firestore
      .collection('orders')
      .snapshots()
      .map((snapshot) {
        print('Stream emitted: ${snapshot.docs.length} docs');
        for (var doc in snapshot.docs) {
          print('Order: ${doc.data()}');
        }
        return snapshot.docs.map((doc) {
          return OrderModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
}
// stream a single order document by its ID
Stream<OrderModel> getOrderStream(String orderId) {
  return _firestore
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .map((snapshot) {
        return OrderModel.fromFirestore(
          snapshot.data()!,
          snapshot.id,
        );
      });
}

// update order status
Future<void> updateOrderStatus(String orderId, String newStatus) async {
  await _firestore.collection('orders').doc(orderId).update({
    'status': newStatus,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  // place order
  Future<OrderModel> placeOrder(
    List<CartItemModel> cartItems,
  ) async {
    final user = FirebaseAuth.instance.currentUser!;

    // get student details
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final studentName =
        userDoc.data()!['name'] as String;

    // calculate wait time
    int estimatedWait = 0;

    for (final cartItem in cartItems) {
      estimatedWait +=
          cartItem.menuItem.prepTimeMinutes *
          cartItem.quantity;
    }

    // convert cart items -> order items
    final orderItems = cartItems.map((cartItem) {
      return OrderItemModel(
        itemId: cartItem.menuItem.id,
        name: cartItem.menuItem.name,
        quantity: cartItem.quantity,
        price: cartItem.menuItem.price,
      );
    }).toList();

    // calculate total amount
    final totalAmount = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final counterRef = _firestore
        .collection('meta')
        .doc('orderCounter');

    final orderRef =
        _firestore.collection('orders').doc();

    await _firestore.runTransaction(
      (transaction) async {
        final counterSnap =
            await transaction.get(counterRef);

        final lastToken =
            counterSnap.data()!['lastTokenNumber']
                as int;

        final newToken = lastToken + 1;

        transaction.update(
          counterRef,
          {
            'lastTokenNumber': newToken,
          },
        );

        transaction.set(
          orderRef,
          {
            'tokenNumber': newToken,
            'studentId': user.uid,
            'studentName': studentName,
            'items': orderItems
                .map((item) => item.toMap())
                .toList(),
            'totalAmount': totalAmount,
            'status': 'pending',
            'estimatedWaitMinutes':
                estimatedWait,
            'createdAt':
                FieldValue.serverTimestamp(),
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );

    final createdOrder =
        await orderRef.get();

    return OrderModel.fromFirestore(
      createdOrder.data()!,
      createdOrder.id,
    );
  }
}
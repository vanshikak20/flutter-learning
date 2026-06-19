import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // fetch all available menu items once
  Future<List<MenuItemModel>> getMenuItems() async {
  final snapshot = await _firestore
      .collection('menuItems')
      .get();  // no where, no orderBy

  print('Total docs fetched: ${snapshot.docs.length}');

  return snapshot.docs.map((doc) {
    print('Doc: ${doc.data()}');
    return MenuItemModel.fromFirestore(doc.data(), doc.id);
  }).toList();
}
}
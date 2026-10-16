import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:automation_app/models/order_model.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  Future<String> saveOrder(Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save order: $e');
    }
  }

  Future<List<Order>> getOrdersByDate(String date) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('date', isEqualTo: date)
          .get();
      return snapshot.docs.map((doc) {
        return Order.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}

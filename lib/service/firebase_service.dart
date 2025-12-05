import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a stream of all tools
  Stream<QuerySnapshot> getTools() {
    return _firestore.collection('tools').snapshots();
  }

  // Add a new tool
  Future<void> addTool(String name, int quantity, int totalQuantity) {
    return _firestore.collection('tools').add({
      'name': name,
      'quantity': quantity,
      'total_quantity': totalQuantity,
    });
  }

  // Update the quantity of an existing tool
  Future<void> updateToolQuantity(String id, int newQuantity) {
    return _firestore.collection('tools').doc(id).update({
      'quantity': newQuantity,
    });
  }

  // Update the total quantity of an existing tool
  Future<void> updateToolTotalQuantity(String id, int newTotalQuantity) {
    return _firestore.collection('tools').doc(id).update({
      'total_quantity': newTotalQuantity,
    });
  }

  // Delete a tool
  Future<void> deleteTool(String id) {
    return _firestore.collection('tools').doc(id).delete();
  }
}
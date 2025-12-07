import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- TOOLS COLLECTION ---

  // Stream semua tools
  Stream<QuerySnapshot> getTools() {
    return _firestore.collection('tools').snapshots();
  }

  // Tambah tool baru
  Future<void> addTool(String name, int quantity, int totalQuantity) {
    return _firestore.collection('tools').add({
      'name': name,
      'quantity': quantity,
      'total_quantity': totalQuantity,
    });
  }

  // Kembalikan stok alat (misal saat pengembalian otomatis / expired)
  Future<void> returnToolStock(String id, int amount) {
    if (amount <= 0) return Future.value();
    return _firestore.collection('tools').doc(id).update({
      'quantity': FieldValue.increment(amount),
    });
  }

  // Update total_quantity alat
  Future<void> updateToolTotalQuantity(String id, int newTotalQuantity) {
    return _firestore.collection('tools').doc(id).update({
      'total_quantity': newTotalQuantity,
    });
  }

  // Hapus tool
  Future<void> deleteTool(String id) {
    return _firestore.collection('tools').doc(id).delete();
  }

  // --- KURANGI STOK BERDASARKAN NAMA (dipakai saat approve peminjaman) ---

  Future<void> decreaseToolStockByName(String name, int amount) async {
    if (amount <= 0) return;

    final snapshot = await _firestore
        .collection('tools')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // ignore: avoid_print
      print('Tool dengan nama "$name" tidak ditemukan.');
      return;
    }

    final doc = snapshot.docs.first;
    final data = doc.data() as Map<String, dynamic>;
    final num currentQty = (data['quantity'] ?? 0) as num;

    num newQty = currentQty - amount;
    if (newQty < 0) newQty = 0;

    await doc.reference.update({'quantity': newQty});
  }

  Future<void> decreaseToolsStockForRequest(List<dynamic> tools) async {
    for (final t in tools) {
      if (t is Map) {
        final map = Map<String, dynamic>.from(t);
        final String? name = map['name'] as String?;
        final int qty = (map['qty'] as int?) ?? 0;

        if (name != null && name.isNotEmpty && qty > 0) {
          await decreaseToolStockByName(name, qty);
        }
      }
    }
  }

  // --- ADJUST STOK MANUAL DARI HALAMAN ADMIN (TOMBOL + / -) ---

  /// Tambah 1 unit alat (fisik) → quantity +1 & total_quantity +1
  Future<void> increaseTool(String id) async {
    await _firestore.collection('tools').doc(id).update({
      'quantity': FieldValue.increment(1),
      'total_quantity': FieldValue.increment(1),
    });
  }

  /// Kurangi 1 unit alat (fisik) → quantity -1 & total_quantity -1
  /// Tidak akan dieksekusi jika quantity / total_quantity sudah 0
  Future<void> decreaseTool(String id) async {
    final docRef = _firestore.collection('tools').doc(id);
    final snap = await docRef.get();

    if (!snap.exists) {
      print('[decreaseTool] Tool $id tidak ditemukan');
      return;
    }

    final data = snap.data() as Map<String, dynamic>;
    final num quantity = (data['quantity'] ?? 0) as num;
    final num totalQuantity = (data['total_quantity'] ?? quantity) as num;

    if (quantity <= 0 || totalQuantity <= 0) {
      print(
          '[decreaseTool] GAGAL: quantity=$quantity, total=$totalQuantity (<= 0)');
      return;
    }

    await docRef.update({
      'quantity': FieldValue.increment(-1),
      'total_quantity': FieldValue.increment(-1),
    });
  }
}

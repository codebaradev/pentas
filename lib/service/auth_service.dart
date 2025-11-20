import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTER USER
  Future<String> registerUser({
    required String username,
    required String nim,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      await _db.collection("users").doc(user.uid).set({
        "nama": username,
        "nim": nim,
        "email": email,
        "role": "mahasiswa",
        "created_at": FieldValue.serverTimestamp(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Terjadi kesalahan";
    }
  }

  // LOGIN PAKAI NIM
  Future<String> loginWithNim({
    required String nim,
    required String password,
  }) async {
    try {
      // Cari user berdasarkan NIM
      var snap = await _db
          .collection("users")
          .where("nim", isEqualTo: nim)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        return "NIM tidak ditemukan";
      }

      var data = snap.docs.first.data();

      if (!data.containsKey("email")) {
        return "Email tidak ditemukan untuk NIM ini";
      }

      String email = data["email"];

      // Login pakai email dari Firestore
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login gagal";
    } catch (e) {
      return "Terjadi kesalahan";
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. REGISTER USER (MAHASISWA) ---
  Future<String> registerUser({
    required String username,
    required String nim,
    required String email,
    required String password,
  }) async {
    try {
      // A. Buat Akun di Authentication (Email & Password)
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // B. Simpan Data Detail ke Firestore
      // Kita otomatis set role menjadi 'mahasiswa'
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': username,
        'nim': nim,
        'email': email,
        'role': 'mahasiswa', // Default role
        'status': 'Aktif',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "success";
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- 2. LOGIN USER (MENGGUNAKAN NIM) ---
  // Karena Firebase Auth butuh Email, kita cari Email dulu berdasarkan NIM
  Future<String?> loginUserWithNim({
    required String nim,
    required String password,
  }) async {
    try {
      // A. Cari User di Firestore berdasarkan NIM
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('nim', isEqualTo: nim)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return "NIM tidak ditemukan.";
      }

      // B. Ambil Email dari dokumen user tersebut
      var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      String? email = userData['email'];

      if (email == null || email.isEmpty) {
        return "Data akun tidak valid (Email tidak ditemukan).";
      }

      // C. Login ke Firebase Auth menggunakan Email & Password
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "success";
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- 3. AMBIL ROLE USER ---
  Future<String> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.get('role') ?? 'mahasiswa';
      }
    }
    return 'mahasiswa'; // Default jika tidak ditemukan
  }

  // --- 3.5. AMBIL DETAIL USER ---
  Future<Map<String, dynamic>?> getUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        return doc.data() as Map<String, dynamic>?;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  // --- 4. LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- HELPER: MENANGANI ERROR FIREBASE ---
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email sudah terdaftar.";
      case 'invalid-email':
        return "Format email tidak valid.";
      case 'weak-password':
        return "Password terlalu lemah.";
      case 'user-not-found':
        return "Pengguna tidak ditemukan.";
      case 'wrong-password':
        return "Password salah.";
      case 'user-disabled':
        return "Akun ini telah dinonaktifkan.";
      default:
        return e.message ?? "Terjadi kesalahan autentikasi.";
    }
  }
}
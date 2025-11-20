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

  // --- 2. LOGIN USER (EMAIL) ---
  // Mengembalikan objek User jika berhasil, atau null jika gagal/error
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
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
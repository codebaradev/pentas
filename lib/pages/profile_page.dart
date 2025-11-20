import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/login_page.dart';
import 'package:pentas/pages/rules_page.dart';
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Tidak melakukan apa-apa jika sudah di halaman ini

    if (index == 0) {
      // Jika menekan "Home", kembali ke halaman Home
      // (Kita asumsikan Home adalah halaman di bawah Profile)
      Navigator.pop(context);
    } 
    else if (index == 1) {
        // Pindah ke Halaman Jadwal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JadwalPage()),
        );
        return;
    }
    else if (index == 2) { 
        // Pindah ke Halaman Form Peminjaman
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
        );
        return;
    } else {
      // TODO: Tambahkan navigasi untuk item lain (History, Notification)
      // Untuk saat ini, kita hanya kembali ke Home dan biarkan Home
      // yang menangani navigasi ke halaman lain
      Navigator.pop(context); 
    }
  }

  // Fungsi untuk Logout
  void _logout() {
    // Kembali ke LoginPage dan hapus semua halaman di atasnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // Hapus semua route
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Akun",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
        // Tombol kembali (back arrow) akan otomatis muncul
      ),
      body: Stack(
        children: [
          // --- Latar Belakang Logo ITH (Watermark) ---
          // Pastikan 'assets/logo-ith.png' sudah ada di pubspec.yaml
          Center(
            child: Opacity(
              opacity: 0.1, // Membuat gambar samar
              child: Image.asset(
                'assets/logo-ith.png',
                width: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // --- Konten Utama Halaman ---
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // 1. Card Header "Profile"
                _buildProfileHeaderCard(),
                const SizedBox(height: 24),
                // 2. Card Info Pengguna
                _buildProfileInfoCard(),
              ],
            ),
          ),
        ],
      ),
      // 3. Bottom Navigation Bar Kustom (Sama seperti Home)
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Card untuk header "Profile"
  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Data diri pengguna.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Card untuk info "Nama, NIM, Email, Status"
  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          _buildInfoRow("Nama", "Dasmae Hudzaifah"),
          const SizedBox(height: 16),
          _buildInfoRow("NIM", "2310 12345"),
          const SizedBox(height: 16),
          _buildInfoRow("Email", "dasmaehudzaifah@mahasiswa.ith.ac.id"),
          const SizedBox(height: 16),
          _buildInfoRow("Status", "Mahasiswa"),
          const SizedBox(height: 32),
          // Tombol Logout
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: cardColor, // Warna oranye
              foregroundColor: Colors.black, // Warna teks
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat baris info (Nama: ... , NIM: ...)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kolom Label (agar rapi)
        SizedBox(
          width: 70, // Beri lebar tetap agar titik dua (:) sejajar
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Text(
          " : ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        // Kolom Value (agar bisa wrap jika panjang)
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET YANG DISALIN DARI HOME/LAB PAGE ---
  Widget _buildCustomBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, // <-- Ini penting (index 4)
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
              activeIcon: Icon(Icons.home),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_outlined),
              label: "Jadwal",
              activeIcon: Icon(Icons.edit_note),
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              label: "Notification",
              activeIcon: Icon(Icons.notifications),
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
              activeIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }

}
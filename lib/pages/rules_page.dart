import 'package:flutter/material.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/login_page.dart';

class PeraturanPage extends StatefulWidget {
  const PeraturanPage({super.key});

  @override
  State<PeraturanPage> createState() => _PeraturanPageState();
}

class _PeraturanPageState extends State<PeraturanPage> {
  int _selectedIndex = 1;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardHeaderColor = const Color(0xFFD98B6A);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Sudah di halaman ini

    if (index == 0) {
      // Kembali ke Home
      Navigator.pop(context);
    } else if (index == 2) {
      // Tombol Add
      print("Tombol Add ditekan!");
      return;
    } else if (index == 4) {
      // Ganti ke Halaman Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
    // TODO: Tambahkan navigasi untuk Notification (index 3)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Aturan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Konten Utama Halaman
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // 1. Header "Hi Dasmae" (Sama seperti Home)
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                // 2. Card "Ketentuan Umum"
                _buildRulesCard(),
                const SizedBox(height: 100), // Spasi di bawah
              ],
            ),
          ),
        ],
      ),
      // 3. Bottom Navigation Bar Kustom (Sama seperti Home)
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Header "Hi Dasmae" (Disalin dari Home)
  Widget _buildWelcomeHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi Dasmae !",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Jalani harimu dengan ceria.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Card untuk "Ketentuan Umum"
  Widget _buildRulesCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Warna oranye muda
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      // ClipRRect agar header di dalamnya ikut melengkung
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header "KETENTUAN UMUM"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: cardHeaderColor, // Warna oranye tua
              child: const Text(
                "KETENTUAN UMUM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Isi Peraturan
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRuleItem(
                    "Peminjam",
                    "Peminjaman hanya dapat dilakukan oleh civitas akademika (mahasiswa, dosen, atau staf) yang terdaftar dan aktif.",
                  ),
                  const SizedBox(height: 16),
                  _buildRuleItem(
                    "Tujuan",
                    "Fasilitas dan peralatan hanya boleh digunakan untuk kegiatan akademik, organisasi kemahasiswaan, atau kegiatan lain yang telah disetujui oleh pihak kampus.",
                  ),
                  const SizedBox(height: 16),
                  _buildRuleItem(
                    "Tanggung Jawab",
                    "Peminjam bertanggung jawab penuh atas keutuhan, kebersihan, dan keamanan fasilitas atau peralatan yang dipinjam selama masa peminjaman.",
                  ),
                  const SizedBox(height: 16),
                  _buildRuleItem(
                    "Reservasi",
                    "Peminjaman harus diajukan setidaknya 1x24 jam (H-1) sebelum waktu penggunaan melalui sistem PENTAS ITH atau petugas terkait.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk membuat item peraturan
  Widget _buildRuleItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4, // Jarak antar baris
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
          currentIndex: _selectedIndex, // <-- Ini penting (index 1)
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
              label: "History",
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
import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
// Ganti 'rules_page.dart' dengan 'peraturan_page.dart' jika itu nama file Anda
import 'package:pentas/pages/rules_page.dart'; 
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';

class KontakPage extends StatefulWidget {
  const KontakPage({super.key});

  @override
  State<KontakPage> createState() => _KontakPageState();
}

class _KontakPageState extends State<KontakPage> {
  int _selectedIndex = 0; 

  // Mendefinisikan warna kustom dari gambar
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  void _onItemTapped(int index) {
      if (index == _selectedIndex) return; // Tidak ada aksi jika di halaman yg sama

      if (index == 0) {
        Navigator.pop(context); // Kembali ke Home
        return;
      }
      
      if (index == 1) {
        // Pindah ke Halaman Jadwal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JadwalPage()),
        );
        return;
      }

      if (index == 2) { 
        // Pindah ke Halaman Form Peminjaman
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
        );
        return;
      }
      
      if (index == 3) { // Index 3 adalah Notifikasi
         print("Tombol Notifikasi ditekan!");
         // TODO: Tambahkan navigasi ke Halaman Notifikasi
         return;
      }

      if (index == 4) { // Index 4 adalah Profile
        Navigator.pushReplacement( // Ganti halaman
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return;
      }
    }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Kontak",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 1. Header "Hi Dasmae !" (Sama seperti Home)
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            // 2. Banner "Selamat Datang !" (Sama seperti Home)
            _buildWelcomeBanner(),
            const SizedBox(height: 24),
            // 3. Judul "Kontak Petugas"
            const Text(
              "Kontak Petugas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // 4. Grid Kontak
            _buildKontakGrid(),
            const SizedBox(height: 20), // Spasi di bawah
          ],
        ),
      ),
      // 5. Bottom Navigation Bar Kustom
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET HELPER ---

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

  // Banner "Selamat Datang" (Disalin dari Home, dengan perbaikan placeholder)
  Widget _buildWelcomeBanner() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Bagian Kiri (Teks)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selamat Datang !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ayo gunakan fasilitas kampus dengan mudah, optimal, dan bijak.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bagian Kanan (Gambar Placeholder)
            Expanded(
              flex: 2,
              child: Container(
                height: 140,
                color: Colors.grey[300], 
                child: Icon(
                  Icons.image_not_supported_outlined, 
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid Kontak 2x2
  Widget _buildKontakGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        // Item 1: WhatsApp
        _buildKontakCard(
          title: "WhatsApp",
          icon: Icons.contact_page_outlined, // Ikon WhatsApp
          iconColor: Colors.green.shade700, // Warna khas WhatsApp
          onTap: () {
            print("Tombol WhatsApp ditekan!");
            // TODO: Tambahkan aksi (misal: buka URL WhatsApp)
          },
        ),
        // Item 2: Gmail
        _buildKontakCard(
          title: "Gmail",
          icon: Icons.mail_outline, // Ikon Gmail
          iconColor: Colors.red.shade700, // Warna khas Gmail
          onTap: () {
            print("Tombol Gmail ditekan!");
            // TODO: Tambahkan aksi (misal: buka email)
          },
        ),
      ],
    );
  }

  // Helper untuk membuat card kontak
  Widget _buildKontakCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor, // Warna oranye
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Icon(icon, size: 80, color: iconColor), // Ikon besar berwarna
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom Nav Bar (Disalin dari halaman lain) ---
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
          currentIndex: _selectedIndex,
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
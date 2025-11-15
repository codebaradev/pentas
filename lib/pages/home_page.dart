import 'package:flutter/material.dart';
import 'package:pentas/pages/lab_page.dart';
import 'package:pentas/pages/tools_page.dart';
 import 'package:pentas/pages/profile_page.dart'; // Import Anda sudah benar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  void _onItemTapped(int index) {
      if (index == 2) {
        print("Tombol Add ditekan");
        return;
      }
      
      // --- TAMBAHKAN LOGIKA NAVIGASI INI ---
      if (index == 4) { // Index 4 adalah Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return; // Jangan setState karena kita pindah halaman
      }
      // TODO: Tambahkan navigasi untuk History (index 1) dan Notification (index 3)
      // --- AKHIR PENAMBAHAN ---
      
      setState(() {
        _selectedIndex = index;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildWelcomeBanner(),
            const SizedBox(height: 24),
            const Text(
              "Menu Application",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuGrid(), // <-- PERBAIKAN UTAMA ADA DI FUNGSI INI
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // Widget Helper
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
          "Jalani harimu dengan ceria",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Banner "Selamat Datang"
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
            Expanded(
              flex: 2,
              child: Image.network(
                'https://placehold.co/200x200/A3C6C4/000000?text=IMG',
                height: 140,
                fit: BoxFit.cover,
                // Error handling sederhana jika gambar gagal dimuat
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FUNGSI INI TELAH DIMODIFIKASI ---
  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2, // 2 kolom
      crossAxisSpacing: 8, // Spasi horizontal
      mainAxisSpacing: 8, // Spasi vertikal
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95, // Aspek rasio dari perbaikan overflow

      children: [
        // Item 1: Laboratorium
        _buildGridItem(
          date: "1 November 2025",
          icon: Icons.computer_outlined,
          title: "Laboratorium",
          subtitle: "Available :",
          count: "3 Rooms",
          // --- INI ADALAH AKSI NAVIGASI YANG ANDA MINTA ---
          onTap: () {
            print("Navigasi ke Halaman Lab..."); // Aksi di konsol
            Navigator.push(
              context,
              MaterialPageRoute(
                // Menggunakan LabPage dari import Anda
                builder: (context) => const LaboratoriumPage(),
              ),
            );
          },
          // --- AKHIR AKSI ---
        ),

        // Item 2: Peralatan
        _buildGridItem(
          date: "1 November 2025",
          icon: Icons.construction_outlined,
          title: "Peralatan",
          subtitle: "Available :",
          count: "8 Tools",
          onTap: () {
            // Aksi: Pindah ke Halaman Peralatan
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PeralatanPage(),
              ),
            );
          },
        ),

        // Item 3: Peraturan
        _buildGridItemSimple(
          icon: Icons.description_outlined,
          title: "Peraturan\nPeminjaman",
          onTap: () {
            // TODO: Tambahkan navigasi untuk Peraturan di sini
            print("Tombol Peraturan ditekan!");
          },
        ),

        // Item 4: Kontak
        _buildGridItemSimple(
          icon: Icons.phone_in_talk_outlined,
          title: "Kontak Petugas\ndan bantuan",
          onTap: () {
            // TODO: Tambahkan navigasi untuk Kontak di sini
            print("Tombol Kontak ditekan!");
          },
        ),
      ],
    );
  }

  // --- FUNGSI HELPER INI TELAH DIMODIFIKASI ---
  // Helper untuk item grid (dengan info 'Available')
  Widget _buildGridItem({
    required String date,
    required IconData icon,
    required String title,
    required String subtitle,
    required String count,
    VoidCallback? onTap, // <-- 1. Menambahkan parameter onTap
  }) {
    return Material( // <-- 2. Mengganti Container dengan Material
      color: cardColor, // <-- 3. Pindahkan properti ke Material
      borderRadius: BorderRadius.circular(20),
      child: InkWell( // <-- 4. Menambahkan InkWell untuk 'action'
        onTap: onTap, // <-- 5. Menghubungkan onTap
        borderRadius: BorderRadius.circular(20), // <-- 6. Agar ripple sesuai
        child: Container( // <-- 7. Container asli
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent, // <-- 8. Warna diatur oleh Material
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column( // Konten tetap sama
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const Spacer(),
              Text(
                count,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI HELPER INI TELAH DIMODIFIKASI ---
  // Helper untuk item grid simpel ('Peraturan' & 'Kontak')
  Widget _buildGridItemSimple({
    required IconData icon,
    required String title,
    VoidCallback? onTap, // <-- 1. Menambahkan parameter onTap
  }) {
    return Material( // <-- 2. Mengganti Container dengan Material
      color: cardColor, // <-- 3. Pindahkan properti ke Material
      borderRadius: BorderRadius.circular(20),
      child: InkWell( // <-- 4. Menambahkan InkWell untuk 'action'
        onTap: onTap, // <-- 5. Menghubungkan onTap
        borderRadius: BorderRadius.circular(20), // <-- 6. Agar ripple sesuai
        child: Container( // <-- 7. Container asli
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent, // <-- 8. Warna diatur oleh Material
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column( // Konten tetap sama
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: Colors.black),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Bar Kustom
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
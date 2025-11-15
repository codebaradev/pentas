import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';

class LaboratoriumPage extends StatefulWidget {
  const LaboratoriumPage({super.key});

  @override
  State<LaboratoriumPage> createState() => _LaboratoriumPageState();
}

class _LaboratoriumPageState extends State<LaboratoriumPage> {
  // Melacak item yang dipilih di Bottom Nav Bar
  int _selectedIndex = 0;

  // Mendefinisikan warna kustom dari gambar
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  // Fungsi untuk menangani klik Bottom Nav Bar
  void _onItemTapped(int index) {
      if (index == 0) {
        Navigator.pop(context); // Kembali ke Home
        return;
      }
      if (index == 2) {
        print("Tombol Add ditekan!");
        return;
      }
      
      // --- TAMBAHKAN LOGIKA NAVIGASI INI ---
      if (index == 4) { // Index 4 adalah Profile
        // Ganti halaman Lab dengan halaman Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        return;
      }
      // TODO: Tambahkan navigasi untuk History (index 1) dan Notification (index 3)
      // --- AKHIR PENAMBAHAN ---
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Laboratorium",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
        // Tombol kembali (back arrow) akan otomatis muncul
        // karena kita menggunakan Navigator.push()
      ),
      body: SingleChildScrollView(
        // Padding utama untuk seluruh konten
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 1. Teks "Dasmae"
            _buildLabHeader(),
            const SizedBox(height: 24),
            // 2. Banner "Laboratory !"
            _buildLabBanner(),
            const SizedBox(height: 24),
            // 3. Judul "Ruangan yang tersedia"
            const Text(
              "Ruangan yang tersedia",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // 4. Grid Ruangan
            _buildRoomGrid(),
            const SizedBox(height: 20), // Spasi di bawah
          ],
        ),
      ),
      // 5. Bottom Navigation Bar Kustom (Sama seperti Home)
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET HELPER ---

  // Header "Dasmae"
  Widget _buildLabHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dasmae",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Ayo gunakan Laboratorium ITH",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Banner "Laboratory" (Mirip dengan di Home)
  Widget _buildLabBanner() {
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
                      "Laboratory !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Laboratorium fasilitas kampus dengan komputer yang memadai.",
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

            // --- PERBAIKAN 1: MENGHILANGKAN ERROR GAMBAR ---
            // Mengganti Image.network (yang error) dengan placeholder
            Expanded(
              flex: 2,
              child: Container(
                height: 140,
                color: Colors.grey[300], // Warna placeholder
                child: Icon(
                  Icons.image_not_supported_outlined, // Ikon placeholder
                  color: Colors.grey[600],
                  size: 40,
                ),
                // --- Ganti dengan ini jika Anda punya gambar lokal ---
                // child: Image.asset(
                //   'assets/images/nama_gambar_anda.png',
                //   height: 140,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            // --- AKHIR PERBAIKAN 1 ---
          ],
        ),
      ),
    );
  }

  // Grid Ruangan 2x2
  Widget _buildRoomGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Menggunakan rasio yang sama dengan home page untuk konsistensi
      childAspectRatio: 0.95,
      children: [
        // Item 1: Room 201
        _buildRoomCard(roomNumber: "201", isAvailable: true),
        // Item 2: Room 202
        _buildRoomCard(roomNumber: "202", isAvailable: true),
        // Item 3: Room 203
        _buildRoomCard(roomNumber: "203", isAvailable: false),
        // Item 4: Room 204
        _buildRoomCard(roomNumber: "204", isAvailable: true),
      ],
    );
  }

  // Helper untuk membuat card ruangan
  Widget _buildRoomCard({
    required String roomNumber,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1 November 2025",
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.computer_outlined, size: 30, color: Colors.black),
              const SizedBox(width: 8),

              // --- PERBAIKAN 2: MENGHILANGKAN OVERFLOW ---
              // Membungkus Column dengan Expanded agar teks otomatis
              // turun (wrap) jika tidak muat.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Laboratorium",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis, // Opsi tambahan
                    ),
                    Text(
                      "Room : $roomNumber",
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              // --- AKHIR PERBAIKAN 2 ---
            ],
          ),
          const Spacer(), // Mendorong status ke bawah
          Text(
            isAvailable ? "Available" : "Not Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: isAvailable ? FontWeight.normal : FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET YANG DISALIN DARI HOME PAGE ---
  // (Pastikan ini identik dengan yang ada di home_page.dart)

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
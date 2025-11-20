import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/rules_page.dart';
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';


class LaboratoriumPage extends StatefulWidget {
  const LaboratoriumPage({super.key});

  @override
  State<LaboratoriumPage> createState() => _LaboratoriumPageState();
}

class _LaboratoriumPageState extends State<LaboratoriumPage> {
  int _selectedIndex = 0;
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  // Fungsi navigasi Bottom Bar yang sudah dilengkapi
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
          "Laboratorium",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildLabHeader(),
            const SizedBox(height: 24),
            _buildLabBanner(),
            const SizedBox(height: 24),
            const Text(
              "Ruangan yang tersedia",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildRoomGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET HELPER ---

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

  // Grid Ruangan 2x2
  Widget _buildRoomGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8, // Mengembalikan ke 8 sesuai kode Anda
      mainAxisSpacing: 8, // Mengembalikan ke 8 sesuai kode Anda
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95, 
      children: [
        // Item 1: Room 201
        _buildRoomCard(roomNumber: "201", isAvailable: true, kapasitas: "49"),
        // Item 2: Room 202
        _buildRoomCard(roomNumber: "202", isAvailable: true, kapasitas: "30"),
        // Item 3: Room 203
        _buildRoomCard(roomNumber: "203", isAvailable: false, kapasitas: "56"),
        // Item 4: Room 204
        _buildRoomCard(roomNumber: "204", isAvailable: true, kapasitas: "56"),
      ],
    );
  }

  // --- PERBAIKAN UTAMA ADA DI FUNGSI INI ---
  Widget _buildRoomCard({
    required String roomNumber,
    required bool isAvailable,
    required String kapasitas,
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
          // 1. Judul "Room 201"
          Text(
            "Room $roomNumber",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12), 

          // 2. Info Lab & Kapasitas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.computer_outlined, size: 30, color: Colors.black),
              const SizedBox(width: 8),
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Teks "Laboratorium"
                    const Text(
                      "Laboratorium",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), 
                    
                    // --- INI PERBAIKANNYA ---
                    // Baris "Kapasitas : 49 [ikon]"
                    Row(
                      children: [
                        // 1. Bungkus Teks dengan Flexible
                        Flexible(
                          child: Text(
                            "Kapasitas : $kapasitas",
                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                            // 2. Tambahkan overflow ellipsis
                            overflow: TextOverflow.ellipsis, 
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.people, size: 14, color: Colors.black54),
                      ],
                    ),
                    // --- AKHIR PERBAIKAN ---
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(), // Mendorong status ke bawah
          
          // 3. Status "Available"
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
  // --- AKHIR PERBAIKAN DESAIN GRID ---


  // --- Bottom Nav Bar (Tidak berubah) ---
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
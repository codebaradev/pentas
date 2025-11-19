import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/rules_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/form_page.dart';

class PeralatanPage extends StatefulWidget {
  const PeralatanPage({super.key});

  @override
  State<PeralatanPage> createState() => _PeralatanPageState();
}

class _PeralatanPageState extends State<PeralatanPage> {
  int _selectedIndex = 0;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardColorBackground = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor= const Color(0xFFFAFAFA);

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    }
    if (index == 2) { 
        // Pindah ke Halaman Form Peminjaman
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
        );
        return;
      }
    
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
          "Peralatan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Padding utama untuk seluruh konten
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // 1. Teks "Dasmae"
            _buildPeralatanHeader(),
            const SizedBox(height: 24),
            // 2. Banner "Laboratory !" (Sama seperti halaman Lab)
            _buildLabBanner(),
            const SizedBox(height: 24),
            // 3. Judul "Peralatan yang tersedia"
            const Text(
              "Peralatan yang tersedia",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // 4. List Peralatan
            _buildToolList(),
            const SizedBox(height: 20), // Spasi di bawah
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET HELPER ---

  // Header "Dasmae" (sedikit beda dari Lab)
  Widget _buildPeralatanHeader() {
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
          "Gunakan alat dengan baik.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Banner "Laboratory" (Disalin dari Lab Page, dengan perbaikan placeholder)
  Widget _buildLabBanner() {
    return Container(
      decoration: BoxDecoration(
        color: cardColorBackground,
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
            // Bagian Kanan (Gambar Placeholder)
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List Peralatan
  Widget _buildToolList() {
    // Menggunakan Column karena ini daftar vertikal, bukan grid
    return Column(
      children: [
        _buildToolCard(
          icon: Icons.videocam_outlined, // Ikon untuk Proyektor
          title: "Proyektor",
          availability: "Available 4/6",
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.power_outlined, // Ikon untuk Terminal Cable
          title: "Terminal Cable",
          availability: "Available 3/7",
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.settings_input_hdmi_outlined, // Ikon untuk HDMI
          title: "HDMI Cable",
          availability: "Available 8/10",
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.draw_outlined, // Ikon untuk Spidol
          title: "Spidol",
          availability: "Available 15/15",
        ),
      ],
    );
  }

  // Helper untuk membuat card peralatan
  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String availability,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          // Aksi ketika item alat ditekan
          print("$title ditekan!");
          // TODO: Tambahkan navigasi ke halaman detail alat jika ada
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent, // Warna dari Material
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.black),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    availability,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
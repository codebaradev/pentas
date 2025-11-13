import 'package:flutter/material.dart';
import 'package:pentas/pages/lab_page.dart';

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

            _buildMenuGrid(),
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
                child:
                    Image.network(
                      // Ganti URL ini dengan gambar aset Anda
                'https://placehold.co/200x200/A3C6C4/000000?text=IMG',
                height: 140,
                fit: BoxFit.cover,
                // Jika Anda punya gambar di folder assets:
                // Image.asset(
                //   'assets/images/nama_gambar_anda.png',
                //   height: 140,
                //   fit: BoxFit.cover,
                // ),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildMenuGrid() {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.95,
        children: [
          // --- MODIFIKASI DIMULAI DI SINI ---
          GestureDetector(
            onTap: () {
              // Navigasi ke Halaman Laboratorium
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LaboratoriumPage(),
                ),
              );
            },
            child: _buildGridItem(
              date: "1 November 2025",
              icon: Icons.computer_outlined,
              title: "Laboratorium",
              subtitle: "Available :",
              count: "3 Rooms",
            ),
          ),
          _buildGridItem(
            date: "1 November 2025",
            icon: Icons.meeting_room_outlined,
            title: "Peralatan",
            subtitle: "Available",
            count: "8 Tools",
          ),
          _buildGridItemSimple(
          icon: Icons.description_outlined,
          title: "Peraturan\nPeminjaman",
          ),
          // Item 4: Kontak
          _buildGridItemSimple(
            icon: Icons.phone_in_talk_outlined,
            title: "Kontak Petugas\ndan bantuan",
          ),
        ],
      );
    }

    // Helper untuk membuat item grid (yang ada info 'Available')
    Widget _buildGridItem({
      required String date,
      required IconData icon,
      required String title,
      required String subtitle,
      required String count,
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
            Text(
              date,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
            // --- DIUBAH (1) ---
            const SizedBox(height: 4), // <-- Diubah dari 8 menjadi 4
            Icon(icon, size: 30, color: Colors.black),
            // --- DIUBAH (2) ---
            const SizedBox(height: 4), // <-- Diubah dari 8 menjadi 4
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Spacer(), // Mendorong 'count' ke bawah
            Text(
              count,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      );
    }

    // Helper untuk membuat item grid (yang simpel, 'Peraturan' & 'Kontak')
  Widget _buildGridItemSimple(
        {required IconData icon, required String title}) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
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
      );
    }

    // Bottom Navigation Bar Kustom
  Widget _buildCustomBottomNav() {
      // Container untuk membuat bayangan dan lengkungan
      return Container(
        height: 80, // Tinggi kustom
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
        // ClipRRect agar BottomNavigationBar di dalamnya ikut melengkung
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor:
                Colors.transparent, // Transparan agar warna Container terlihat
            elevation: 0, // Hapus bayangan default
            type: BottomNavigationBarType.fixed, // Tampilkan semua label
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              // Item 1: Home
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "Home",
                activeIcon: Icon(Icons.home),
              ),
              // Item 2: History
              const BottomNavigationBarItem(
                icon: Icon(Icons.edit_note_outlined),
                label: "History",
                activeIcon: Icon(Icons.edit_note),
              ),
              // Item 3: Tombol Add (+) Kustom
              BottomNavigationBarItem(
                label: "", // Tidak ada label
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
              // Item 4: Notification
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_outlined),
                label: "Notification",
                activeIcon: Icon(Icons.notifications),
              ),
              // Item 5: Profile
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



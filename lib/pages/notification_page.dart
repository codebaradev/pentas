import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/rules_page.dart'; // Ganti dengan peraturan_page.dart jika nama file berbeda
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3;

  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color cardBackgroundColor = const Color(0xFF2A2A2A); // Latar belakang hitam untuk notifikasi
  final Color greenBorderColor = const Color(0xFF67E082); // Hijau untuk 'Setujui'
  final Color redBorderColor = const Color(0xFFFF4D4D); // Merah untuk 'Tolak'

  final List<Map<String, dynamic>> _notifications = [
    {
      "message": "Peminjaman Ruangan 203 di Setujui !",
      "status": "approved", // approved, rejected
    },
    {
      "message": "Peminjaman Ruangan 201 di Tolak !",
      "status": "rejected",
    },
    {
      "message": "Peminjaman 2 Projektor di Tolak !",
      "status": "rejected",
    },
    {
      "message": "Peminjaman Spidol di Setujui !",
      "status": "approved",
    },
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JadwalPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // 1. Header "Hi Dasmae"
            _buildHeader(),
            const SizedBox(height: 24),
            
            // 2. Daftar Notifikasi (Card Hitam Besar)
            _buildNotificationContainer(),
            
            const SizedBox(height: 100), // Spasi bawah
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeader() {
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
      ],
    );
  }

  Widget _buildNotificationContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Warna Hitam/Gelap
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notifikasi",
            style: TextStyle(
              color: Color(0xFFF9A887), // Warna Oranye untuk Judul
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // List Notifikasi
          ListView.builder(
            shrinkWrap: true, // Agar bisa di dalam Column/SingleScrollView
            physics: const NeverScrollableScrollPhysics(), // Scroll mengikuti parent
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return _buildNotificationItem(
                message: notif['message'],
                isApproved: notif['status'] == 'approved',
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper: Item Notifikasi (Tombol Putih dengan Border Hijau/Merah)
  Widget _buildNotificationItem({required String message, required bool isApproved}) {
    // Kita perlu memisahkan teks untuk styling (misal: "di Setujui !" berwarna hijau)
    // Untuk simplifikasi sesuai gambar, kita gunakan RichText atau deteksi kata kunci.
    
    Color statusColor = isApproved ? greenBorderColor : redBorderColor;
    String statusText = isApproved ? "Setujui !" : "Tolak !";
    
    // Memotong pesan agar kita bisa mewarnai statusnya
    // Asumsi pesan selalu diakhiri dengan status
    String mainText = message.replaceAll(statusText, "");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Sudut sangat bulat (kapsul)
        border: Border.all(
          color: statusColor, // Border warna Hijau atau Merah
          width: 3, // Border tebal sesuai gambar
        ),
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87, // Warna teks utama (sedikit abu agar tidak terlalu kontras)
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: mainText), // Teks utama ("Peminjaman Ruangan 203 di ")
              TextSpan(
                text: statusText, // Teks status ("Setujui !")
                style: TextStyle(
                  color: statusColor, // Warna status (Hijau/Merah)
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

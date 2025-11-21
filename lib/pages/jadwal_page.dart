import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
// Ganti import ini jika path file Anda berbeda
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/service/auth_service.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final AuthService _authService = AuthService();
  String _username = "Pengguna"; // Nilai default

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _username = userDetails['name'] ?? "Pengguna";
      });
    }
  }

  int _selectedIndex = 1;

  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color headerDarkColor = const Color(0xFF2A2A2A); // Warna header tabel (gelap)
  final Color rowLightColor = const Color(0xFFE0E0E0); // Warna baris tabel (abu muda)

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      // Kembali ke Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (index == 2) {
      // Tombol Add -> Form Peminjaman
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
      );
    } else if (index == 4) {
      // Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
    // TODO: Index 3 (Notification)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Jadwal",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Tidak ada tombol kembali di root nav
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
            
            // 2. Tabel Jadwal
            _buildScheduleTable(),
            
            const SizedBox(height: 100), // Spasi bawah
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi $_username!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTable() {
    return Container(
      decoration: BoxDecoration(
        color: headerDarkColor, // Latar belakang utama gelap
        borderRadius: BorderRadius.circular(20),
      ),
      // ClipRRect agar anak-anaknya tidak keluar dari radius border
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // --- Bagian Header "Jadwal Laboratorium" ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: headerDarkColor,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jadwal Laboratorium",
                    style: TextStyle(
                      color: Color(0xFFF9A887), // Warna oranye teks
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Kamis, 20 - Nov -2025",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // --- Baris Jadwal 1 (Isi) ---
            _buildScheduleRow("Ruangan 203", "08:45 - 10:30"),
            
            // --- Baris Jadwal Kosong (Placeholder) ---
            // Tambahkan beberapa baris kosong untuk visual sesuai gambar
            _buildEmptyRow(),
            _buildEmptyRow(),
            _buildEmptyRow(),

            // --- Area Kosong Bawah (Hitam/Gelap) ---
            // Sisa ruang di bawah diisi warna gelap agar sesuai desain
            Container(
              height: 200, // Tinggi area kosong bawah
              color: headerDarkColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String room, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: rowLightColor, // Abu-abu muda
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 1), // Garis pemisah hitam
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            room,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Baris Jadwal Kosong
  Widget _buildEmptyRow() {
    return Container(
      height: 45, // Tinggi baris kosong
      decoration: BoxDecoration(
        color: rowLightColor,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }

  // --- Bottom Nav Bar ---
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
          currentIndex: _selectedIndex, // Index 1 = Jadwal
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFFF9A887), // Warna Latar Nav Bar ORANYE (sesuai gambar)
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
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
              icon: Icon(Icons.edit_note), // Ikon aktif untuk Jadwal
              label: "Jadwal",
              activeIcon: Icon(Icons.edit_note),
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2), // Border hitam
                  color: Colors.transparent, // Transparan agar warna oranye tembus? atau putih?
                  // Di gambar terlihat plus dalam lingkaran hitam
                ),
                child: const Icon(Icons.add_circle_outline, color: Colors.black, size: 40),
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
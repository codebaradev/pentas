import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pentas/pages/lab_page.dart';
import 'package:pentas/pages/tools_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/rules_page.dart';
import 'package:pentas/pages/kontak_page.dart';
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'package:pentas/service/auth_service.dart';
import 'package:pentas/service/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  String _username = "Pengguna";
  int _selectedIndex = 0;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardBackgroundColor = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _getCurrentSessionName() {
    final now = TimeOfDay.now();
    final double currentTime = now.hour + now.minute / 60.0;

    if (currentTime >= 7.0 && currentTime < 8.67) return "Sesi 1: 07.00-08.40"; // 08:40
    if (currentTime >= 8.75 && currentTime < 10.42) return "Sesi 2: 08.45-10.25"; // 10:25
    if (currentTime >= 10.5 && currentTime < 12.17) return "Sesi 3: 10.30-12.10"; // 12:10
    if (currentTime >= 13.5 && currentTime < 15.17) return "Sesi 4: 13.30-15.10"; // 15:10
    if (currentTime >= 15.25 && currentTime < 16.92) return "Sesi 5: 15.15-16.55"; // 16:55
    if (currentTime >= 17.0 && currentTime < 18.67) return "Sesi 6: 17.00-18.40"; // 18:40
    
    return null; // Diluar jam sesi
  }

  Future<void> _loadUserData() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _username = userDetails['name'] ?? "Pengguna";
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JadwalPage()),
      );
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
      );
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotificationPage()),
      );
      return;
    }
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
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

  Widget _buildWelcomeHeader() {
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
        const SizedBox(height: 4),
        const Text(
          "Mulai aktivitasmu dengan fokus dan semangat baru untuk mencapai hasil terbaik hari ini.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

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
                      "Manfaatkan fasilitas kampus secara optimal sebagai dukungan bagi produktivitas dan perjalanan akademikmu.",
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
                child: Image.asset(
                  'assets/lab_ith.jpg',
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    );
                  },
                ),
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: [
        _buildLabCard(),
        _buildToolsCard(),
        _buildGridItemSimple(
          icon: Icons.description_outlined,
          title: "Peraturan\nPeminjaman",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PeraturanPage(),
              ),
            );
          },
        ),
        _buildGridItemSimple(
          icon: Icons.phone_in_talk_outlined,
          title: "Kontak Petugas\ndan bantuan",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KontakPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabCard() {
    final String? currentSession = _getCurrentSessionName();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    if (currentSession == null) {
      return _buildLabCardUI(4, "Diluar Sesi");
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .where('date', isEqualTo: Timestamp.fromDate(startOfToday))
          .where('session', isEqualTo: currentSession)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLabCardUI(4, "Memuat...");
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildLabCardUI(4, "Semua Tersedia");
        }

        final busyRooms =
            snapshot.data!.docs.map((doc) => doc['room']).toSet();
        final availableRooms = 4 - busyRooms.length;
        final statusText = availableRooms == 0 ? "Penuh" : "$availableRooms/4 Tersedia";

        return _buildLabCardUI(availableRooms, statusText);
      },
    );
  }

  Widget _buildLabCardUI(int availableRooms, String statusText) {
    Color statusColor;
    if (statusText == "Diluar Sesi" || statusText == "Memuat...") {
      statusColor = Colors.grey;
    } else if (availableRooms == 4) {
      statusColor = Colors.green;
    } else if (availableRooms == 0) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LaboratoriumPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!, width: 1),
                    ),
                    child: Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 9,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.computer_outlined,
                        size: 28, color: Colors.black),
                    const SizedBox(height: 8),
                    const Text(
                      "Laboratorium",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Ruang komputer tersedia",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$availableRooms dari 4 Ruang",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: availableRooms / 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card Peralatan yang diperbarui
  Widget _buildToolsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tools') // Pastikan collection name sama
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Tampilkan loading atau default
          return _buildToolsCardLoading();
        }

        final tools = snapshot.data!.docs;
        int availableTools = 0;
        int totalTools = 0;

        for (var tool in tools) {
          final toolData = tool.data() as Map<String, dynamic>;
          final int currentQuantity = (toolData['quantity'] as int?) ?? 0;
          final int totalQuantity = (toolData['total_quantity'] as int?) ?? currentQuantity;
          
          availableTools += currentQuantity;
          totalTools += totalQuantity;
        }

        String statusText;
        Color statusColor;
        double availability = totalTools > 0 ? availableTools / totalTools : 0;

        if (availability >= 0.7) {
          statusText = "Banyak Tersedia";
          statusColor = Colors.green;
        } else if (availability >= 0.3) {
          statusText = "Cukup Tersedia";
          statusColor = Colors.orange;
        } else {
          statusText = "Terbatas";
          statusColor = Colors.red;
        }

        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PeralatanPage()),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[300]!, width: 1),
                        ),
                        child: Text(
                          "LIVE",
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor, width: 1),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 9,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Konten utama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.construction_outlined,
                            size: 28, color: Colors.black),
                        const SizedBox(height: 8),
                        const Text(
                          "Peralatan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Proyektor, kabel, spidol",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Footer dengan info dan progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$availableTools dari $totalTools Alat",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: availability,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Tambahkan fungsi loading untuk saat data belum tersedia
  Widget _buildToolsCardLoading() {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PeralatanPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status loading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!, width: 1),
                    ),
                    child: Text(
                      "LIVE",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: Text(
                      "Memuat...",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Konten utama
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.construction_outlined,
                        size: 28, color: Colors.black),
                    const SizedBox(height: 8),
                    const Text(
                      "Peralatan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Proyektor, kabel, spidol",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Footer dengan info loading
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Memuat data...",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: null,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk item grid simpel ('Peraturan' & 'Kontak')
  Widget _buildGridItemSimple({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: Colors.black),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13, // Ukuran dikurangi sedikit
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2, // Line height dikurangi
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
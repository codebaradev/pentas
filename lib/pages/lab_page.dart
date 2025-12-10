import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/service/auth_service.dart';
import 'dart:async';

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

  final AuthService _authService = AuthService();
  String _username = "Pengguna";

  Map<String, List<String>> _roomBusySessions = {
    "Ruangan Kelas 201": [],
    "Ruangan Kelas 202": [],
    "Ruangan Kelas 203": [],
    "Ruangan Kelas 204": [],
  };

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

  void _processSnapshotForToday(List<QueryDocumentSnapshot> docs) {
    Map<String, List<String>> tempBusySessions = {
      "Ruangan Kelas 201": [],
      "Ruangan Kelas 202": [],
      "Ruangan Kelas 203": [],
      "Ruangan Kelas 204": [],
    };

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String? roomName = data['room'];
      String? sessionString = data['session'];

      if (roomName != null &&
          sessionString != null &&
          tempBusySessions.containsKey(roomName)) {
        String sessionName = sessionString.split(':')[0].trim();
        tempBusySessions[roomName]!.add(sessionName);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _roomBusySessions.toString() != tempBusySessions.toString()) {
        setState(() {
          _roomBusySessions = tempBusySessions;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pop(context);
      return;
    }
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
      Navigator.pushReplacement(
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
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: () {
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final endOfToday = startOfToday.add(const Duration(days: 1));

          return FirebaseFirestore.instance
              .collection('requests')
              .where('status', isEqualTo: 'accepted')
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
              .where('date', isLessThan: Timestamp.fromDate(endOfToday))
              .snapshots();
        }(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _processSnapshotForToday(snapshot.data!.docs);
          }
          return SingleChildScrollView(
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
          );
        },
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildRoomGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        _buildRoomCard("Ruangan Kelas 201", "201", "49"),
        _buildRoomCard("Ruangan Kelas 202", "202", "30"),
        _buildRoomCard("Ruangan Kelas 203", "203", "56"),
        _buildRoomCard("Ruangan Kelas 204", "204", "56"),
      ],
    );
  }

  Widget _buildRoomCard(
      String roomName, String roomNumber, String capacity) {
    return InkWell(
      onTap: () => _showRoomDetails(roomName, roomNumber, capacity),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black54, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ruangan $roomNumber",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.computer_outlined, size: 30),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Laboratorium",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "Kapasitas : $capacity",
                          style: const TextStyle(fontSize: 9),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.people, size: 10),
                      ],
                    ),
                  ],
                )
              ],
            ),
            const Spacer(),
            const Text(
              "Ketuk untuk lihat detail",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(
      String roomName, String roomNumber, String capacity) {
    final busySessions = _roomBusySessions[roomName] ?? [];
    final allSessions = [
      "Sesi 1 (07.00 - 08.40)",
      "Sesi 2 (08.45 - 10.25)",
      "Sesi 3 (10.30 - 12.10)",
      "Sesi 4 (13.30 - 15.10)",
      "Sesi 5 (15.15 - 16.55)",
      "Sesi 6 (17.00 - 18.40)",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detail Ruangan $roomNumber",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allSessions.length,
                  itemBuilder: (context, index) {
                    final fullSessionName = allSessions[index];
                    final shortSessionName = fullSessionName.split('(')[0].trim();
                    final isBooked = busySessions.contains(shortSessionName);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isBooked ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fullSessionName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            isBooked ? "Booked" : "Available",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBooked ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Akses ruang laboratorium yang nyaman dan siap mendukung kebutuhan komputasimu secara efektif.",
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
                      "Laboratorium!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gunakan setiap fasilitas laboratorium dengan bijak agar kegiatan belajar berjalan lancar dan terarah.",
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
              activeIcon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_outlined),
              label: "Jadwal",
              activeIcon: Icon(Icons.calendar_today),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 0),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              label: "Notifikasi",
              activeIcon: Icon(Icons.notifications),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profil",
              activeIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}

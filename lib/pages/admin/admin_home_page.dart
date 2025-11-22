import 'package:flutter/material.dart';
import 'package:pentas/pages/login_page.dart';
import 'package:pentas/service/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  String? _adminName;

  final Color primaryColor = const Color(0xFF526D9D); // Biru Gelap (Header/Sidebar)
  final Color cardColor = const Color(0xFFC8D6F5); // Biru Muda (Card)
  final Color backgroundColor = const Color(0xFFFFFFFF); // Putih

  @override
  void initState() {
    super.initState();
    _loadAdminDetails();
  }

  Future<void> _loadAdminDetails() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _adminName = userDetails['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _adminName != null ? "Hi $_adminName" : "Loading...",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
      
      // --- SIDEBAR (DRAWER) ---
      drawer: _buildSidebar(),

      // --- BODY UTAMA ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Laboratory Computer
            const Center(
              child: Text(
                "Laboratory Computer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRoomGrid(),

            const SizedBox(height: 30),

            // Section 2: Laboratory Tools
            const Center(
              child: Text(
                "Laboratory Tools",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildToolList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: primaryColor, // Warna latar Drawer Biru Gelap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50), // Spasi atas pengganti Header
          
          // Menu Item 1: Permintaan
          ListTile(
            title: const Text(
              "Permintaan yang masuk",
              style: TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
            onTap: () {
              // TODO: Navigasi ke halaman request
              Navigator.pop(context); 
            },
          ),
          
          // Menu Item 2: Ketersediaan (Halaman Aktif)
          Container(
            decoration: const BoxDecoration(
               border: Border(bottom: BorderSide(color: Colors.black, width: 1))
            ),
            child: ListTile(
              title: const Text(
                "Ketersediaan Ruang dan Alat",
                style: TextStyle(
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline, // Garis bawah teks
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
              },
            ),
          ),

          const Spacer(), // Dorong Logout ke bawah

          // Tombol Logout
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  // Logika Logout
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252), // Warna Merah
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRoomGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.95,
      children: [
        _buildRoomCard("201", true, "49"),
        _buildRoomCard("202", true, "30"),
        _buildRoomCard("203", false, "56"),
        _buildRoomCard("204", true, "56"),
      ],
    );
  }

  Widget _buildRoomCard(String roomNumber, bool isAvailable, String capacity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor, // Warna Biru Muda
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Room $roomNumber",
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
                  const Text("Laboratorium", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text("Kapasitas : $capacity", style: const TextStyle(fontSize: 9)),
                      const SizedBox(width: 2),
                      const Icon(Icons.people, size: 10),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isAvailable ? "Available" : "Not Available",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- WIDGET LIST ALAT ---
  Widget _buildToolList() {
    return Column(
      children: [
        _buildToolCard("Projektor", "4/6", Icons.videocam_outlined),
        const SizedBox(height: 12),
        _buildToolCard("Terminal Cable", "3/7", Icons.power_outlined),
        const SizedBox(height: 12),
        _buildToolCard("HDMI Cable", "8/10", Icons.settings_input_hdmi_outlined),
        const SizedBox(height: 12),
        _buildToolCard("Spidol", "15/15", Icons.edit),
      ],
    );
  }

  Widget _buildToolCard(String name, String stock, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor, // Warna Biru Muda
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Available $stock",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


}
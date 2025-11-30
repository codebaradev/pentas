import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib Import
import 'package:pentas/pages/login_page.dart';
import 'package:pentas/service/auth_service.dart'; // Pastikan path benar
import 'package:pentas/pages/admin/create_dosen_page.dart';
import 'package:pentas/pages/admin/permintaan_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  String? _adminName;

  final Color primaryColor = const Color(0xFF526D9D); 
  final Color cardColor = const Color(0xFFC8D6F5); 
  final Color backgroundColor = const Color(0xFFFFFFFF);

  // --- STOK AWAL ALAT ---
  final Map<String, int> _initialToolStock = {
    "Proyektor": 6,
    "Terminal Kabel": 7,
    "HDMI Kabel": 10,
    "Spidol": 15,
  };

  // Data Realtime
  Map<String, int> _currentToolStock = {};
  // Kita ubah struktur ini untuk menyimpan List Sesi yang sibuk per ruangan
  // Contoh: "Ruangan Kelas 201": ["Sesi 1", "Sesi 3"]
  Map<String, List<String>> _roomBusySessions = {
    "Ruangan Kelas 201": [],
    "Ruangan Kelas 202": [],
    "Ruangan Kelas 203": [],
    "Ruangan Kelas 204": [],
  };

  @override
  void initState() {
    super.initState();
    _loadAdminDetails();
    _currentToolStock = Map.from(_initialToolStock);
  }

  Future<void> _loadAdminDetails() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _adminName = userDetails['name'];
      });
    }
  }

  // Helper: Mendapatkan Sesi Saat Ini (untuk indikator realtime)
  String _getCurrentSession() {
    final now = TimeOfDay.now();
    final double time = now.hour + now.minute / 60.0;

    if (time >= 7.0 && time <= 8.66) return "Sesi 1";
    if (time >= 8.75 && time <= 10.41) return "Sesi 2";
    if (time >= 10.5 && time <= 12.16) return "Sesi 3";
    if (time >= 13.5 && time <= 15.16) return "Sesi 4";
    if (time >= 15.25 && time <= 16.91) return "Sesi 5";
    if (time >= 17.0 && time <= 18.66) return "Sesi 6";
    
    return "Diluar Jam";
  }

  // --- PROSES DATA FIREBASE ---
  void _processSnapshot(List<QueryDocumentSnapshot> docs) {
    Map<String, int> tempStock = Map.from(_initialToolStock);
    
    // Reset data sesi sibuk
    Map<String, List<String>> tempBusySessions = {
      "Ruangan Kelas 201": [],
      "Ruangan Kelas 202": [],
      "Ruangan Kelas 203": [],
      "Ruangan Kelas 204": [],
    };

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // 1. Hitung Stok Alat
      if (data['hasTools'] == true && data['tools'] != null) {
        List tools = data['tools'];
        for (var tool in tools) {
          String name = tool['name'];
          int qty = tool['qty'];
          if (tempStock.containsKey(name)) {
            tempStock[name] = (tempStock[name]! - qty).clamp(0, 999);
          }
        }
      }

      // 2. Petakan Sesi Sibuk per Ruangan
      String? roomName = data['room'];
      String? sessionString = data['session']; // "Sesi 1: 07.00..."
      
      if (roomName != null && sessionString != null) {
        String sessionName = sessionString.split(':')[0].trim(); // Ambil "Sesi 1"
        
        if (tempBusySessions.containsKey(roomName)) {
          tempBusySessions[roomName]!.add(sessionName);
        }
      }
    }

    _currentToolStock = tempStock;
    _roomBusySessions = tempBusySessions;
  }

  // --- DIALOG DETAIL RUANGAN ---
  void _showRoomDetails(String roomName, String roomCapacity) {
    List<String> busySessions = _roomBusySessions["Ruangan Kelas $roomName"] ?? [];
    List<String> allSessions = [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detail Room $roomName", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF526D9D))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text("Kapasitas: $roomCapacity", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Status Ketersediaan Hari Ini:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              
              // List Sesi
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allSessions.length,
                  itemBuilder: (context, index) {
                    String fullSessionName = allSessions[index];
                    String shortSessionName = fullSessionName.split(' ')[0] + " " + fullSessionName.split(' ')[1]; // "Sesi 1"
                    bool isBooked = busySessions.contains(shortSessionName);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isBooked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isBooked ? Colors.red : Colors.green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fullSessionName, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              Icon(isBooked ? Icons.block : Icons.check_circle, size: 16, color: isBooked ? Colors.red : Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                isBooked ? "Booked" : "Available",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBooked ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 30),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _adminName != null ? "Hi $_adminName" : "Loading...",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      drawer: _buildSidebar(),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _processSnapshot(snapshot.data!.docs);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text("Waktu Sekarang: ${_getCurrentSession()}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
                ),

                const Center(child: Text("Laboratory Computer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
                const SizedBox(height: 4),
                const Center(child: Text("(Ketuk ruangan untuk melihat detail sesi)", style: TextStyle(fontSize: 12, color: Colors.grey))),
                const SizedBox(height: 16),
                
                _buildRoomGrid(),

                const SizedBox(height: 30),

                const Center(child: Text("Laboratory Tools", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black))),
                const SizedBox(height: 16),
                _buildToolList(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ... (Kode _buildSidebar SAMA seperti sebelumnya) ...
  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          ListTile(
            title: const Text("Permintaan yang masuk", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PermintaanPage()));
            },
          ),
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
            child: ListTile(
              title: const Text("Ketersediaan Ruang dan Alat", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.underline)),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Container(
             decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
             child: ListTile(
               leading: const Icon(Icons.person_add, color: Colors.black),
               title: const Text("Buat Akun Dosen", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
               onTap: () {
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateDosenPage()));
               },
             ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () async {
                  await _authService.signOut();
                  if(!mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Colors.black)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text("Logout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        _buildRoomCard("201", "49"),
        _buildRoomCard("202", "30"),
        _buildRoomCard("203", "56"),
        _buildRoomCard("204", "56"),
      ],
    );
  }

  Widget _buildRoomCard(String roomNumber, String capacity) {
    // Cek apakah sesi SEKARANG sedang dipakai
    String currentSession = _getCurrentSession();
    List<String> busySessions = _roomBusySessions["Ruangan Kelas $roomNumber"] ?? [];
    bool isNowBusy = busySessions.contains(currentSession);

    return InkWell(
      onTap: () => _showRoomDetails(roomNumber, capacity), // Buka Modal Detail
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
            Text("Room $roomNumber", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            // Indikator Visual Status (Sesi Ini)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNowBusy ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isNowBusy ? Colors.red : Colors.green),
              ),
              child: Text(
                isNowBusy ? "Dipakai" : "Available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNowBusy ? Colors.red[800] : Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolList() {
    return Column(
      children: [
        _buildToolCard("Proyektor", "${_currentToolStock['Proyektor']}/${_initialToolStock['Proyektor']}", Icons.videocam_outlined),
        const SizedBox(height: 12),
        _buildToolCard("Terminal Kabel", "${_currentToolStock['Terminal Kabel']}/${_initialToolStock['Terminal Kabel']}", Icons.power_outlined),
        const SizedBox(height: 12),
        _buildToolCard("HDMI Kabel", "${_currentToolStock['HDMI Kabel']}/${_initialToolStock['HDMI Kabel']}", Icons.settings_input_hdmi_outlined),
        const SizedBox(height: 12),
        _buildToolCard("Spidol", "${_currentToolStock['Spidol']}/${_initialToolStock['Spidol']}", Icons.edit),
      ],
    );
  }

  Widget _buildToolCard(String name, String stock, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
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
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Available $stock", style: const TextStyle(fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }


}
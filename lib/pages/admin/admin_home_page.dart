import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Timer? _refreshTimer; // <-- HAPUS INI

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
    
    // --- HAPUS TIMER DI SINI ---
    // StreamBuilder sudah cukup untuk update realtime.
  }

  // @override
  // void dispose() {
  //   _refreshTimer?.cancel(); // <-- HAPUS INI
  //   super.dispose();
  // }

  Future<void> _loadAdminDetails() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _adminName = userDetails['name'];
      });
    }
  }

  // ... (Sisa kode Helper, _processSnapshot, dll TETAP SAMA) ...

  // SAYA SARANKAN COPY PASTE ULANG BAGIAN _processSnapshot KE BAWAH
  // UNTUK MEMASTIKAN LOGIKANYA SAMA
  
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
  
  DateTime _parseSessionEndTime(String session, DateTime scheduleDate) {
      // ... (Kode parser waktu Anda tetap sama) ...
      try {
      if (session.contains(':') && session.contains('-')) {
        final parts = session.split(':');
        if (parts.length > 1) {
          final timePart = parts[1].trim();
          final timeRange = timePart.split('-');
          if (timeRange.length == 2) {
            final endTimeStr = timeRange[1].trim();
            final endParts = endTimeStr.split('.');
            
            if (endParts.length == 2) {
              final endHour = int.parse(endParts[0]);
              final endMinute = int.parse(endParts[1]);
              
              return DateTime(
                scheduleDate.year,
                scheduleDate.month,
                scheduleDate.day,
                endHour,
                endMinute,
              );
            }
          }
        }
      }
    } catch (e) {
      print("Error parsing session time: $e");
    }
    return scheduleDate.add(const Duration(hours: 2));
  }

  void _processSnapshot(List<QueryDocumentSnapshot> docs) {
    Map<String, int> tempStock = Map.from(_initialToolStock);
    
    Map<String, List<String>> tempBusySessions = {
      "Ruangan Kelas 201": [],
      "Ruangan Kelas 202": [],
      "Ruangan Kelas 203": [],
      "Ruangan Kelas 204": [],
    };

    final now = DateTime.now();

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final status = data['status'];
      
      if (status == 'accepted') {
        if (data['hasTools'] == true && data['tools'] != null) {
          List tools = data['tools'];
          
          Timestamp? dateTimestamp = data['date'] as Timestamp?;
          String? session = data['session'];
          
          if (dateTimestamp != null && session != null) {
            DateTime scheduleDate = dateTimestamp.toDate();
            DateTime endTime = _parseSessionEndTime(session, scheduleDate);
            
            if (now.isBefore(endTime)) {
              for (var tool in tools) {
                String name = tool['name'];
                int qty = tool['qty'];
                if (tempStock.containsKey(name)) {
                  tempStock[name] = (tempStock[name]! - qty).clamp(0, _initialToolStock[name]!);
                }
              }
            }
          }
        }

        String? roomName = data['room'];
        String? sessionString = data['session'];
        Timestamp? dateTimestamp = data['date'];
        
        if (roomName != null && sessionString != null && dateTimestamp != null) {
          DateTime scheduleDate = dateTimestamp.toDate();
          DateTime endTime = _parseSessionEndTime(sessionString, scheduleDate);
          
          if (now.isBefore(endTime)) {
            String sessionName = sessionString.split(':')[0].trim();
            
            if (tempBusySessions.containsKey(roomName)) {
              tempBusySessions[roomName]!.add(sessionName);
            }
          }
        }
      }
    }

    // --- PENTING: GUNAKAN microtask UNTUK MENGHINDARI ERROR SETSTATE ---
    Future.microtask(() {
        if (mounted) {
          setState(() {
            _currentToolStock = tempStock;
            _roomBusySessions = tempBusySessions;
          });
        }
    });
  }
  
  // ... (Sisa kode _showRoomDetails, build, _buildSidebar, dll SAMA)
  
  // Sertakan sisa fungsi build dan helper widget Anda di sini...
  // Saya potong agar tidak terlalu panjang, tapi pastikan logic di atas diganti.
  
  @override
  Widget build(BuildContext context) {
      // ... (Sama seperti sebelumnya)
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
            // .where('status', isEqualTo: 'accepted') // Opsional filter di sini atau di process
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Panggil fungsi proses
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
  
  void _showRoomDetails(String roomNumber, String capacity) {
    final roomName = "Ruangan Kelas $roomNumber";
    List<String> busySessions = _roomBusySessions[roomName] ?? [];
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
                  Text("Detail Room $roomNumber", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF526D9D))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                    child: Text("Kapasitas: $capacity", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
      onTap: () => _showRoomDetails(roomNumber, capacity),
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
        // Menggunakan data dinamis dari _currentToolStock
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
      // ... Logic yang sama seperti kode Anda sebelumnya ...
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
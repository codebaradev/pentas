import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pentas/pages/login_page.dart';
import 'package:pentas/service/auth_service.dart';
import 'package:pentas/service/firebase_service.dart';
import 'package:pentas/pages/admin/create_dosen_page.dart';
import 'package:pentas/pages/admin/permintaan_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  String? _adminName;
  Timer? _scheduleTimer;

  final Color primaryColor = const Color(0xFF526D9D);
  final Color cardColor = const Color(0xFFC8D6F5);
  final Color backgroundColor = const Color(0xFFFFFFFF);

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
    _startAutoReturnCheck();
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

  void _startAutoReturnCheck() {
    _processExpiredRequests();
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _processExpiredRequests();
    });
  }

  Future<void> _processExpiredRequests() async {
    try {
      final now = DateTime.now();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .get();

      final toolsSnapshot =
          await FirebaseFirestore.instance.collection('tools').get();
      final Map<String, String> toolIds = {
        for (var doc in toolsSnapshot.docs) doc.data()['name']: doc.id,
      };

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final session = data['session'] as String?;
        final date = data['date'] as Timestamp?;

        if (session != null && date != null) {
          final scheduleDate = date.toDate();
          final endTime = _parseSessionEndTime(session, scheduleDate);

          if (now.isAfter(endTime.add(const Duration(minutes: 5)))) {
            if (data['hasTools'] == true && data['tools'] != null) {
              List requestedTools = data['tools'];
              for (var toolItem in requestedTools) {
                String toolName = toolItem['name'];
                int qtyToReturn =
                    int.tryParse(toolItem['qty'].toString()) ?? 0;

                if (toolIds.containsKey(toolName) && qtyToReturn > 0) {
                  String toolId = toolIds[toolName]!;
                  await _firebaseService.returnToolStock(toolId, qtyToReturn);
                  debugPrint("Auto-returned: $toolName ($qtyToReturn)");
                }
              }
            }

            await FirebaseFirestore.instance
                .collection('requests')
                .doc(doc.id)
                .delete();
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking expired requests: $e");
    }
  }

  Future<void> _loadAdminDetails() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _adminName = userDetails['name'];
      });
    }
  }

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
      debugPrint("Error parsing session time: $e");
    }
    return scheduleDate.add(const Duration(hours: 2));
  }

  /// Supaya baca angka dari Firestore aman (int / double / String / null)
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _processSnapshot(List<QueryDocumentSnapshot> docs) {
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
        String? roomName = data['room'];
        String? sessionString = data['session'];
        Timestamp? dateTimestamp = data['date'];

        if (roomName != null &&
            sessionString != null &&
            dateTimestamp != null) {
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

    Future.microtask(() {
      if (mounted) {
        setState(() {
          _roomBusySessions = tempBusySessions;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
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
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Waktu Sekarang: ${_getCurrentSession()}",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _showAddToolDialog,
                    child: const Text('Add New Tool'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddToolDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Tool'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tool Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Total Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final quantity = int.tryParse(quantityController.text);
                if (name.isNotEmpty && quantity != null && quantity > 0) {
                  await _firebaseService.addTool(name, quantity, quantity);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseService.getTools(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tools = snapshot.data!.docs;
        if (tools.isEmpty) {
          return const Text("Belum ada data alat.");
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _buildToolCard(tool);
          },
        );
      },
    );
  }

  Widget _buildToolCard(DocumentSnapshot tool) {
    final toolData = tool.data() as Map<String, dynamic>;
    final String name = (toolData['name'] ?? '').toString();
    final int quantity = _safeInt(toolData['quantity']);
    final int totalQuantity =
        _safeInt(toolData['total_quantity'] ?? toolData['quantity']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Available: $quantity / $totalQuantity",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          // Kurangi stok (pakai get + FieldValue.increment)
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () async {
              try {
                final docRef =
                    FirebaseFirestore.instance.collection('tools').doc(tool.id);
                final snapshot = await docRef.get();
                if (!snapshot.exists) return;

                final data = snapshot.data() as Map<String, dynamic>;
                final currentQty = _safeInt(data['quantity']);

                if (currentQty > 0) {
                  await docRef.update({
                    'quantity': FieldValue.increment(-1),
                  });
                }
              } catch (e, st) {
                debugPrint('Error decrement tool: $e');
                debugPrint(st.toString());
              }
            },
          ),
          // Tambah stok (pakai get + FieldValue.increment)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              try {
                final docRef =
                    FirebaseFirestore.instance.collection('tools').doc(tool.id);
                final snapshot = await docRef.get();
                if (!snapshot.exists) return;

                final data = snapshot.data() as Map<String, dynamic>;
                final currentQty = _safeInt(data['quantity']);
                final currentTotal =
                    _safeInt(data['total_quantity'] ?? data['quantity']);

                if (currentQty < currentTotal) {
                  await docRef.update({
                    'quantity': FieldValue.increment(1),
                  });
                }
              } catch (e, st) {
                debugPrint('Error increment tool: $e');
                debugPrint(st.toString());
              }
            },
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditToolDialog(tool.id, name, quantity, totalQuantity);
            },
          ),
          // Hapus
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteToolDialog(tool.id, name);
            },
          ),
        ],
      ),
    );
  }

  void _showEditToolDialog(
    String toolId,
    String currentName,
    int currentQty,
    int currentTotal,
  ) {
    final nameController = TextEditingController(text: currentName);
    final qtyController = TextEditingController(text: currentQty.toString());
    final totalController =
        TextEditingController(text: currentTotal.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Tool'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nama Alat'),
              ),
              TextField(
                controller: totalController,
                decoration:
                    const InputDecoration(labelText: 'Total Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(
                    labelText: 'Available Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newTotal = int.tryParse(totalController.text) ?? 0;
                final newQty = int.tryParse(qtyController.text) ?? 0;

                if (newName.isEmpty ||
                    newTotal <= 0 ||
                    newQty < 0 ||
                    newQty > newTotal) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pastikan nama terisi, total > 0 dan available tidak lebih dari total.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('tools')
                      .doc(toolId)
                      .update({
                    'name': newName,
                    'total_quantity': newTotal,
                    'quantity': newQty,
                  });
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error updating tool: $e');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteToolDialog(String toolId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Alat'),
          content: Text(
            'Yakin ingin menghapus "$name" dari daftar alat?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('tools')
                      .doc(toolId)
                      .delete();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  debugPrint('Error deleting tool: $e');
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
            title: const Text(
              "Permintaan yang masuk",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermintaanPage(),
                ),
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: ListTile(
              title: const Text(
                "Ketersediaan Ruang dan Alat",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.person_add, color: Colors.black),
              title: const Text(
                "Buat Akun Dosen",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDosenPage(),
                  ),
                );
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
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
        _buildRoomCard("201", "49"),
        _buildRoomCard("202", "30"),
        _buildRoomCard("203", "56"),
        _buildRoomCard("204", "56"),
      ],
    );
  }

  Widget _buildRoomCard(String roomNumber, String capacity) {
    String currentSession = _getCurrentSession();
    List<String> busySessions =
        _roomBusySessions["Ruangan Kelas $roomNumber"] ?? [];
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
            Text(
              "Room $roomNumber",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNowBusy
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isNowBusy ? Colors.red : Colors.green,
                ),
              ),
              child: Text(
                isNowBusy ? "Not Available" : "Available",
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
                  Text(
                    "Detail Room $roomNumber",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF526D9D),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Kapasitas: $capacity",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Status Ketersediaan Hari Ini:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allSessions.length,
                  itemBuilder: (context, index) {
                    String fullSessionName = allSessions[index];
                    String shortSessionName = fullSessionName.split(' ')[0] +
                        " " +
                        fullSessionName.split(' ')[1];
                    bool isBooked = busySessions.contains(shortSessionName);

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
                          color:
                              isBooked ? Colors.red : Colors.green,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fullSessionName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                isBooked
                                    ? Icons.block
                                    : Icons.check_circle,
                                size: 16,
                                color: isBooked
                                    ? Colors.red
                                    : Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isBooked ? "Booked" : "Available",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isBooked
                                      ? Colors.red
                                      : Colors.green,
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
}

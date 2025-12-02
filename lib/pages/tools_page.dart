import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription<QuerySnapshot>? _subscription;

  final Color cardColor = const Color(0xFFF9A887);
  final Color cardColorBackground = const Color(0xFFFFF0ED);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  // --- STOK AWAL ALAT (sama dengan admin) ---
  final Map<String, int> _initialToolStock = {
    "Proyektor": 6,
    "Terminal Cable": 7,
    "HDMI Cable": 10,
    "Spidol": 15,
  };

  // Data Realtime
  Map<String, int> _currentToolStock = {};

  @override
  void initState() {
    super.initState();
    _currentToolStock = Map.from(_initialToolStock);
    _setupFirestoreListener();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupFirestoreListener() {
    _subscription = FirebaseFirestore.instance
        .collection('requests')
        .snapshots()
        .listen((snapshot) {
      _processSnapshot(snapshot.docs);
    });
  }

  // Fungsi untuk mem-parsing waktu akhir sesi
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
      print("Error parsing session time: $e");
    }
    return scheduleDate.add(const Duration(hours: 2));
  }

  // Fungsi untuk memproses snapshot dari Firestore
  void _processSnapshot(List<QueryDocumentSnapshot> docs) {
    Map<String, int> tempStock = Map.from(_initialToolStock);
    final now = DateTime.now();

    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final status = data['status'];

      // Hanya proses request yang sudah diterima
      if (status == 'accepted') {
        if (data['hasTools'] == true && data['tools'] != null) {
          List tools = data['tools'];

          Timestamp? dateTimestamp = data['date'] as Timestamp?;
          String? session = data['session'];

          if (dateTimestamp != null && session != null) {
            DateTime scheduleDate = dateTimestamp.toDate();
            DateTime endTime = _parseSessionEndTime(session, scheduleDate);

            // Cek apakah pemesanan alat masih aktif (belum berakhir)
            if (now.isBefore(endTime)) {
              for (var tool in tools) {
                String name = tool['name'];
                int qty = tool['qty'];
                
                // Normalisasi nama alat untuk kecocokan
                String normalizedName = name;
                if (name == "Terminal Kabel") {
                  normalizedName = "Terminal Cable";
                } else if (name == "HDMI Kabel") {
                  normalizedName = "HDMI Cable";
                }
                
                if (tempStock.containsKey(normalizedName)) {
                  tempStock[normalizedName] =
                      (tempStock[normalizedName]! - qty)
                          .clamp(0, _initialToolStock[normalizedName]!);
                }
              }
            }
          }
        }
      }
    }

    // Update state jika ada perubahan
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentToolStock = tempStock;
        });
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PeraturanPage()),
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
      // Navigasi ke notification page jika ada
      return;
    }

    if (index == 4) {
      Navigator.pushReplacement(
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
          "Peralatan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildPeralatanHeader(),
            const SizedBox(height: 24),
            _buildLabBanner(),
            const SizedBox(height: 24),
            const Text(
              "Peralatan yang tersedia",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildToolList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Laboratory Tools",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tersedia berbagai peralatan pendukung untuk kegiatan akademik.",
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
                  // Error handling sederhana jika gambar gagal dimuat
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

  Widget _buildToolList() {
    return Column(
      children: [
        _buildToolCard(
          icon: Icons.videocam_outlined,
          title: "Proyektor",
          availability: "Available ${_currentToolStock['Proyektor'] ?? _initialToolStock['Proyektor'] ?? 0}/${_initialToolStock['Proyektor'] ?? 0}",
          stock: _currentToolStock['Proyektor'] ?? _initialToolStock['Proyektor'] ?? 0,
          maxStock: _initialToolStock['Proyektor'] ?? 0,
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.power_outlined,
          title: "Terminal Cable",
          availability: "Available ${_currentToolStock['Terminal Cable'] ?? _initialToolStock['Terminal Cable'] ?? 0}/${_initialToolStock['Terminal Cable'] ?? 0}",
          stock: _currentToolStock['Terminal Cable'] ?? _initialToolStock['Terminal Cable'] ?? 0,
          maxStock: _initialToolStock['Terminal Cable'] ?? 0,
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.settings_input_hdmi_outlined,
          title: "HDMI Cable",
          availability: "Available ${_currentToolStock['HDMI Cable'] ?? _initialToolStock['HDMI Cable'] ?? 0}/${_initialToolStock['HDMI Cable'] ?? 0}",
          stock: _currentToolStock['HDMI Cable'] ?? _initialToolStock['HDMI Cable'] ?? 0,
          maxStock: _initialToolStock['HDMI Cable'] ?? 0,
        ),
        const SizedBox(height: 16),
        _buildToolCard(
          icon: Icons.draw_outlined,
          title: "Spidol",
          availability: "Available ${_currentToolStock['Spidol'] ?? _initialToolStock['Spidol'] ?? 0}/${_initialToolStock['Spidol'] ?? 0}",
          stock: _currentToolStock['Spidol'] ?? _initialToolStock['Spidol'] ?? 0,
          maxStock: _initialToolStock['Spidol'] ?? 0,
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String availability,
    required int stock,
    required int maxStock,
  }) {
    // Tentukan warna berdasarkan ketersediaan
    Color statusColor;
    if (stock == 0) {
      statusColor = Colors.red;
    } else if (stock <= maxStock * 0.3) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          _showToolDetails(title, stock, maxStock);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.black),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 8),
                    // Progress bar untuk visualisasi ketersediaan
                    LinearProgressIndicator(
                      value: stock / maxStock,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  stock > 0 ? "Tersedia" : "Habis",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToolDetails(String toolName, int currentStock, int maxStock) {
    double percentage = (currentStock / maxStock) * 100;
    String statusText;
    Color statusColor;
    
    if (currentStock == 0) {
      statusText = "Habis";
      statusColor = Colors.red;
    } else if (currentStock <= maxStock * 0.3) {
      statusText = "Terbatas";
      statusColor = Colors.orange;
    } else if (currentStock <= maxStock * 0.7) {
      statusText = "Cukup";
      statusColor = Colors.blue;
    } else {
      statusText = "Banyak";
      statusColor = Colors.green;
    }

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
                "Detail $toolName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status:", style: TextStyle(fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Stok saat ini
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Stok Tersedia:", style: TextStyle(fontSize: 16)),
                  Text(
                    "$currentStock dari $maxStock",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Persentase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Persentase:", style: TextStyle(fontSize: 16)),
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              LinearProgressIndicator(
                value: currentStock / maxStock,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                borderRadius: BorderRadius.circular(10),
                minHeight: 20,
              ),
              
              const SizedBox(height: 20),
              
              // Keterangan
              Text(
                "Data diperbarui secara real-time berdasarkan peminjaman yang aktif.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
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
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'package:intl/intl.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  // Data User (Default)
  String _name = "Memuat...";
  String _nim = "Memuat...";
  String _status = "Memuat...";

  int _selectedIndex = 2;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whatsappController = TextEditingController(text: "085342614904");
  bool _isLoading = false;

  // Data Pilihan Form
  DateTime? _selectedDate;
  String? _selectedRoom;
  final List<String> _roomList = [
    "Ruangan Kelas 201", "Ruangan Kelas 202", "Ruangan Kelas 203", "Ruangan Kelas 204",
  ];

  String? _selectedSession;
  final List<String> _sessionList = [
    "Sesi 1: 07.00-08.40", "Sesi 2: 08.45-10.25", "Sesi 3: 10.30-12.10",
    "Sesi 4: 13.30-15.10", "Sesi 5: 15.15-16.55", "Sesi 6: 17.00-18.40",
  ];

  // Logika Fasilitas
  bool _isBorrowingFacilities = false; 
  List<Map<String, dynamic>> _selectedFacilities = [
    {'name': 'Proyektor', 'qty': 1} 
  ];
  final List<String> _facilityOptions = [
    "Proyektor", "Terminal Kabel", "HDMI Kabel", "Spidol", "Lainnya"
  ];

  // Warna
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardHeaderColor = const Color(0xFFC06035);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color inputFillColor = const Color(0xFFFFE0D6);

  // STOK AWAL UNTUK VALIDASI
  final Map<String, int> _initialToolStock = {
    "Proyektor": 6,
    "Terminal Kabel": 7,
    "HDMI Kabel": 10,
    "Spidol": 15,
    "Lainnya": 999,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. AMBIL DATA USER DARI FIREBASE ---
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && mounted) {
          setState(() {
            _name = userDoc.get('name') ?? 'Tanpa Nama';
            _nim = userDoc.get('nim') ?? '-'; 
            String role = userDoc.get('role') ?? 'mahasiswa';
            _status = role == 'dosen' || role == 'admin' ? 'Dosen/Admin' : 'Mahasiswa';
          });
        }
      } catch (e) {
        print("Error fetching user: $e");
      }
    }
  }

  // FUNGSI PARSE WAKTU AKHIR SESI
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

  // --- 2. LOGIKA SUBMIT KE FIREBASE DENGAN VALIDASI REAL-TIME ---
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi dropdown dan tanggal
    if (_selectedRoom == null || _selectedSession == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi Tanggal, Ruangan, dan Sesi Waktu")),
      );
      return;
    }

    // **VALIDASI REAL-TIME: CEK KETERSEDIAAN**
    try {
      final now = DateTime.now();
      
      // 1. Cek apakah ruangan sudah dipesan di sesi yang sama (HANYA YANG MASIH AKTIF)
      final roomCheckSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('room', isEqualTo: _selectedRoom)
          .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
          .where('status', isEqualTo: 'accepted')
          .get();

      for (var doc in roomCheckSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final existingSession = data['session'] as String?;
        final existingDate = data['date'] as Timestamp?;
        
        if (existingSession != null && existingSession == _selectedSession && existingDate != null) {
          DateTime scheduleDate = existingDate.toDate();
          DateTime endTime = _parseSessionEndTime(existingSession, scheduleDate);
          
          // Hanya tolak jika jadwal masih aktif
          if (now.isBefore(endTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Ruangan $_selectedRoom sudah dipesan pada $existingSession"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }

      // 2. Cek stok alat (jika meminjam alat) - HANYA YANG MASIH AKTIF
      if (_isBorrowingFacilities) {
        // Ambil semua permintaan yang disetujui untuk tanggal yang sama
        final toolCheckSnapshot = await FirebaseFirestore.instance
            .collection('requests')
            .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
            .where('hasTools', isEqualTo: true)
            .where('status', isEqualTo: 'accepted')
            .get();

        // Hitung total alat yang sudah dipesan (HANYA YANG MASIH AKTIF)
        Map<String, int> usedTools = {};
        for (var doc in toolCheckSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final tools = data['tools'] as List<dynamic>?;
          final session = data['session'] as String?;
          final date = data['date'] as Timestamp?;
          
          // CEK APAKAH JADWAL MASIH AKTIF
          if (tools != null && session != null && date != null) {
            DateTime scheduleDate = date.toDate();
            DateTime endTime = _parseSessionEndTime(session, scheduleDate);
            
            if (now.isBefore(endTime)) {
              for (var tool in tools) {
                String toolName = tool['name'];
                int toolQty = tool['qty'];
                usedTools[toolName] = (usedTools[toolName] ?? 0) + toolQty;
              }
            }
          }
        }

        // Cek apakah stok mencukupi
        for (var selectedTool in _selectedFacilities) {
          String toolName = selectedTool['name'];
          int requestedQty = selectedTool['qty'];
          int availableQty = _initialToolStock[toolName]! - (usedTools[toolName] ?? 0);
          
          if (requestedQty > availableQty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Stok $toolName tidak mencukupi. Tersedia: $availableQty"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
    } catch (e) {
      print("Error checking availability: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal memeriksa ketersediaan. Silakan coba lagi."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      // Siapkan data alat (hanya jika switch ON)
      List<Map<String, dynamic>> toolsData = [];
      if (_isBorrowingFacilities) {
        toolsData = _selectedFacilities;
      }

      // Kirim ke Firestore -> Collection 'requests'
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user?.uid,
        'name': _name,
        'nim': _nim,
        'role': _status,
        'whatsapp': _whatsappController.text,
        'date': Timestamp.fromDate(_selectedDate!),
        'room': _selectedRoom,
        'session': _selectedSession,
        'tools': toolsData,
        'hasTools': _isBorrowingFacilities,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'notificationRead': false,
        'notificationMessage': '', 
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil 🎉"),
            content: const Text("Permintaan peminjaman telah dikirim. Silakan tunggu persetujuan Admin."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim data: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Navigasi Bottom Bar
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (r) => false);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const JadwalPage()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
    } else if (index == 4) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
  }

  // Helper Tambah/Hapus Fasilitas
  void _addFacility() {
    setState(() {
      _selectedFacilities.add({'name': _facilityOptions.first, 'qty': 1});
    });
  }

  void _removeFacility(int index) {
    setState(() {
      _selectedFacilities.removeAt(index);
    });
  }

  // --- Kalender ---
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text("Peminjaman", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hi $_name !", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: cardHeaderColor,
              child: const Text("Form Peminjaman", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info User Statis
                    _buildStaticInfoRow("Nama", _name),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("NIM", _nim),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("Status", _status),
                    const SizedBox(height: 20),

                    // WhatsApp
                    _buildInputLabel("WhatsApp"),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(),
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Ruangan
                    _buildInputLabel("Ruangan"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      hint: const Text("Pilih Ruangan"),
                      decoration: _inputDecoration(),
                      items: _roomList.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _selectedRoom = v),
                    ),
                    const SizedBox(height: 16),

                    // Input Tanggal
                    _buildInputLabel("Tanggal Pinjam"),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? "Pilih Tanggal"
                              : DateFormat('EEEE, d MMMM y', 'id_ID').format(_selectedDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sesi Waktu
                    _buildInputLabel("Waktu (Sesi)"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedSession,
                      hint: const Text("Pilih Sesi"),
                      decoration: _inputDecoration(),
                      items: _sessionList.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _selectedSession = v),
                    ),
                    const SizedBox(height: 16),

                    // Switch Fasilitas
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: const Text("Pinjam Fasilitas Tambahan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        value: _isBorrowingFacilities,
                        activeColor: cardHeaderColor,
                        onChanged: (v) => setState(() => _isBorrowingFacilities = v),
                      ),
                    ),

                    // List Alat (Jika switch ON) - BAGIAN YANG DIPERBAIKI
                    if (_isBorrowingFacilities) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label dan tombol dalam row dengan overflow handling
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: _buildInputLabel("Daftar Alat"),
                                ),
                              ),
                              InkWell(
                                onTap: _addFacility,
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 80),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle, size: 16),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "Tambah",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // List alat dengan perbaikan layout
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedFacilities.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // Dropdown untuk nama alat
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        constraints: const BoxConstraints(minWidth: 120),
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedFacilities[index]['name'],
                                          isDense: true,
                                          isExpanded: true,
                                          decoration: _inputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          items: _facilityOptions
                                              .map((f) => DropdownMenuItem(
                                                    value: f,
                                                    child: Text(
                                                      f,
                                                      style: const TextStyle(fontSize: 13),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (v) => setState(() => _selectedFacilities[index]['name'] = v),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    
                                    // Field untuk jumlah
                                    SizedBox(
                                      width: 55,
                                      child: TextFormField(
                                        initialValue: _selectedFacilities[index]['qty'].toString(),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: _inputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                        ),
                                        onChanged: (v) {
                                          if (v.isNotEmpty) {
                                            setState(() {
                                              _selectedFacilities[index]['qty'] = int.tryParse(v) ?? 1;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    
                                    // Tombol hapus (jika lebih dari 1 alat)
                                    if (_selectedFacilities.length > 1)
                                      SizedBox(
                                        width: 36,
                                        child: IconButton(
                                          icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 36),
                                          onPressed: () => _removeFacility(index),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Text("Dengan ini saya akan mengikuti seluruh aturan yang berlaku sebagai mana yang telah terlampir pada halaman Aturan !!!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.justify),
                    const SizedBox(height: 20),

                    // Tombol Batal & Submit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                            : const Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers UI
  Widget _buildStaticInfoRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
      const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]);
  }

  Widget _buildInputLabel(String label) {
    return Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
      const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
    ]);
  }

  InputDecoration _inputDecoration({EdgeInsetsGeometry? contentPadding}) {
    return InputDecoration(
      filled: true,
      fillColor: inputFillColor,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black54)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black54)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 10)]),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, onTap: _onItemTapped, backgroundColor: Colors.transparent, elevation: 0, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.black, unselectedItemColor: Colors.grey[600], showSelectedLabels: true, showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home", activeIcon: Icon(Icons.home)),
            const BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), label: "Jadwal", activeIcon: Icon(Icons.edit_note)),
            BottomNavigationBarItem(label: "", icon: Container(width: 45, height: 45, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black), child: const Icon(Icons.add, color: Colors.white, size: 30))),
            const BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: "Notification", activeIcon: Icon(Icons.notifications)),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile", activeIcon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
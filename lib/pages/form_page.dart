import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'package:intl/intl.dart';
import 'package:pentas/service/firebase_service.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  // Data user
  String _name = "Memuat...";
  String _nim = "Memuat...";
  String _status = "Memuat...";

  int _selectedIndex = 2;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whatsappController =
      TextEditingController(text: "085342614904");
  bool _isLoading = false;

  final FirebaseService _firebaseService = FirebaseService();

  /// data tools dari Firestore
  Map<String, Map<String, dynamic>> _toolDetails = {};
  List<String> _facilityOptions = [];

  /// subscription ke collection `tools`
  StreamSubscription<QuerySnapshot>? _toolsSubscription;

  // Data Pilihan Form
  DateTime? _selectedDate;
  String? _selectedRoom;
  final List<String> _roomList = [
    "Ruangan Kelas 201",
    "Ruangan Kelas 202",
    "Ruangan Kelas 203",
    "Ruangan Kelas 204",
  ];

  String? _selectedSession;
  final List<String> _sessionList = [
    "Sesi 1: 07.00-08.40",
    "Sesi 2: 08.45-10.25",
    "Sesi 3: 10.30-12.10",
    "Sesi 4: 13.30-15.10",
    "Sesi 5: 15.15-16.55",
    "Sesi 6: 17.00-18.40",
  ];

  // --- START: Perbaikan Logika Pengecekan Sesi ---
  Set<String> _bookedSessions = {};
  bool _isCheckingSessions = false;
  // --- END: Perbaikan Logika Pengecekan Sesi ---

  // Logika Fasilitas
  bool _isBorrowingFacilities = false;
  List<Map<String, dynamic>> _selectedFacilities = [
    {'name': 'Proyektor', 'qty': 1}
  ];

  // Warna
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardHeaderColor = const Color(0xFFC06035);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color inputFillColor = const Color(0xFFFFE0D6);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _listenTools();
  }

  @override
  void dispose() {
    // hentikan listen tools agar tidak ada setState setelah halaman ditutup
    _toolsSubscription?.cancel();
    _whatsappController.dispose();
    super.dispose();
  }

  void _listenTools() {
    _toolsSubscription = _firebaseService.getTools().listen((snapshot) {
      if (!mounted) return;

      if (snapshot.docs.isEmpty) return;

      final Map<String, Map<String, dynamic>> details = {};
      final List<String> options = [];

      for (var tool in snapshot.docs) {
        final toolData = tool.data() as Map<String, dynamic>;
        final String name = toolData['name'];
        details[name] = {
          'quantity': toolData['quantity'],
          'id': tool.id,
        };
        options.add(name);
      }

      setState(() {
        _toolDetails = details;
        _facilityOptions = options;

        // kalau pilihan awal sudah tidak ada di daftar, ganti ke item pertama
        if (_selectedFacilities.isNotEmpty &&
            _facilityOptions.isNotEmpty &&
            !_facilityOptions.contains(_selectedFacilities.first['name'])) {
          _selectedFacilities.first['name'] = _facilityOptions.first;
        }
      });
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final role = userDoc.get('role') ?? 'mahasiswa';
        setState(() {
          _name = userDoc.get('name') ?? 'Tanpa Nama';
          _nim = userDoc.get('nim') ?? '-';
          _status =
              (role == 'dosen' || role == 'admin') ? 'Dosen/Admin' : 'Mahasiswa';
        });
      }
    } catch (e) {
      // boleh kamu kasih snackbar kalau mau
      debugPrint("Error fetching user: $e");
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoom == null ||
        _selectedSession == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi Tanggal, Ruangan, dan Sesi Waktu"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ---- CEK BENTROK RUANG & STOK ALAT (di sisi user) ----
    try {
      final roomCheckSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('room', isEqualTo: _selectedRoom)
          .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
          .where('session', isEqualTo: _selectedSession)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();

      if (roomCheckSnapshot.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Ruangan $_selectedRoom untuk sesi ini sudah dipesan."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_isBorrowingFacilities) {
        for (var selectedTool in _selectedFacilities) {
          final String toolName = selectedTool['name'];
          final int requestedQty = selectedTool['qty'];
          final int availableQty = _toolDetails[toolName]?['quantity'] ?? 0;

          if (requestedQty > availableQty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Stok $toolName tidak mencukupi. Tersedia: $availableQty"),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking availability: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memeriksa ketersediaan. Silakan coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // ---- KIRIM REQUEST KE FIRESTORE ----
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      List<Map<String, dynamic>> toolsData = [];
      if (_isBorrowingFacilities) {
        toolsData = _selectedFacilities;
      }
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

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Berhasil 🎉"),
          content: const Text(
            "Permintaan peminjaman telah dikirim. Silakan tunggu persetujuan Admin.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- NAV BOTTOM -----------------

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (r) => false,
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JadwalPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPage()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }

  void _addFacility() {
    setState(() {
      if (_facilityOptions.isNotEmpty) {
        _selectedFacilities
            .add({'name': _facilityOptions.first, 'qty': 1});
      }
    });
  }

  void _removeFacility(int index) {
    setState(() {
      _selectedFacilities.removeAt(index);
    });
  }

  Future<void> _updateAvailableSessions() async {
    if (_selectedDate == null || _selectedRoom == null) {
      if(mounted) setState(() => _bookedSessions.clear());
      return;
    }

    if(mounted) setState(() => _isCheckingSessions = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .where('room', isEqualTo: _selectedRoom)
          .where('date', isEqualTo: Timestamp.fromDate(_selectedDate!))
          .get();

      final booked =
          snapshot.docs.map((doc) => doc.data()['session'] as String).toSet();

      if (mounted) {
        setState(() {
          _bookedSessions = booked;
        });
      }
    } catch (e) {
      debugPrint("Error checking sessions: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat jadwal sesi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingSessions = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSession = null;
      });
      _updateAvailableSessions();
    }
  }

  // ---------------- UI BUILD -------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Peminjaman",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
        Text(
          "Hi $_name !",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // ---------- sisanya (form card, dekorasi, bottom nav) ----------
  // Bagian di bawah ini sama persis dengan punyamu yang terakhir,
  // jadi tidak aku ubah selain yang perlu.

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
              child: const Text(
                "Form Peminjaman",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaticInfoRow("Nama", _name),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("NIM", _nim),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("Status", _status),
                    const SizedBox(height: 20),
                    _buildInputLabel("WhatsApp"),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(),
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildInputLabel("Ruangan"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      hint: const Text("Pilih Ruangan"),
                      decoration: _inputDecoration(),
                      items: _roomList
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedRoom = v;
                          _selectedSession = null;
                        });
                        _updateAvailableSessions();
                      },
                    ),
                    const SizedBox(height: 16),
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
                              : DateFormat('EEEE, d MMMM y', 'id_ID')
                                  .format(_selectedDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputLabel("Waktu (Sesi)"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedSession,
                      hint: Text(_isCheckingSessions ? "Memeriksa..." : "Pilih Sesi"),
                      decoration: _inputDecoration(),
                      items: _sessionList.map((s) {
                        final isBooked = _bookedSessions.contains(s);
                        return DropdownMenuItem(
                          value: s,
                          enabled: !isBooked,
                          child: Text(
                            isBooked ? "$s (Dipesan)" : s,
                            style: TextStyle(
                              fontSize: 14,
                              color: isBooked ? Colors.grey : null,
                              decoration:
                                  isBooked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedSession = v),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          "Pinjam Fasilitas Tambahan?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        value: _isBorrowingFacilities,
                        activeColor: cardHeaderColor,
                        onChanged: (v) =>
                            setState(() => _isBorrowingFacilities = v),
                      ),
                    ),
                    if (_isBorrowingFacilities) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  constraints:
                                      const BoxConstraints(maxWidth: 80),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_circle, size: 16),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "Tambah",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
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
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedFacilities.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 120,
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          value:
                                              _selectedFacilities[index]['name'],
                                          isDense: true,
                                          isExpanded: true,
                                          decoration: _inputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                          ),
                                          items: _facilityOptions
                                              .map(
                                                (f) => DropdownMenuItem(
                                                  value: f,
                                                  child: Text(
                                                    f,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) => setState(() =>
                                              _selectedFacilities[index]
                                                  ['name'] = v),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 55,
                                      child: TextFormField(
                                        initialValue:
                                            _selectedFacilities[index]['qty']
                                                .toString(),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: _inputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 4,
                                          ),
                                        ),
                                        onChanged: (v) {
                                          if (v.isNotEmpty) {
                                            setState(() {
                                              _selectedFacilities[index]['qty'] =
                                                  int.tryParse(v) ?? 1;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (_selectedFacilities.length > 1)
                                      SizedBox(
                                        width: 36,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.cancel,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                          ),
                                          onPressed: () =>
                                              _removeFacility(index),
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
                    const Text(
                      "Dengan ini saya akan mengikuti seluruh aturan yang berlaku sebagaimana yang telah terlampir pada halaman Aturan !!!",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Batal",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  Widget _buildStaticInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const Text(
          ": ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const Text(
          ": ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({EdgeInsetsGeometry? contentPadding}) {
    return InputDecoration(
      filled: true,
      fillColor: inputFillColor,
      contentPadding:
          contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
                width: 45,
                height: 45,
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

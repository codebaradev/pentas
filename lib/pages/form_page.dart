import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Wajib: Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Wajib: Auth
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
// import 'package:pentas/service/auth_service.dart'; // Tidak wajib di sini, kita pakai direct firestore

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  // Data User (Diambil otomatis)
  String _name = "Memuat...";
  String _nim = "Memuat...";
  String _status = "Memuat...";

  int _selectedIndex = 2; // Index tombol Add

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whatsappController = TextEditingController(text: "085342614904");
  bool _isLoading = false; // Loading indicator

  // Data Pilihan
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
  bool _isBorrowingFacilities = false; // Default false agar rapi
  List<Map<String, dynamic>> _selectedFacilities = [
    {'name': 'Proyektor', 'qty': 1} 
  ];
  final List<String> _facilityOptions = [
    "Proyektor", "Terminal Kabel", "HDMI Kabel", "Spidol", "Lainnya"
  ];

  // Warna UI
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardHeaderColor = const Color(0xFFC06035);
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color inputFillColor = const Color(0xFFFFE0D6);

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Ambil data user saat init
  }

  // --- 1. AMBIL DATA USER DARI FIREBASE ---
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _name = userDoc.get('name') ?? 'Tanpa Nama';
          _nim = userDoc.get('nim') ?? '-';
          _status = userDoc.get('status') ?? 'Mahasiswa';
        });
      }
    }
  }

  // --- 2. LOGIKA SUBMIT KE FIREBASE ---
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null || _selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Ruangan dan Sesi!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      // Siapkan data alat (jika switch ON)
      List<Map<String, dynamic>> toolsData = [];
      if (_isBorrowingFacilities) {
        toolsData = _selectedFacilities;
      }

      // Simpan ke Firestore: Collection 'requests'
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user?.uid,
        'name': _name,
        'nim': _nim,
        'role': _status,
        'whatsapp': _whatsappController.text,
        'room': _selectedRoom,
        'session': _selectedSession,
        'tools': toolsData,
        'hasTools': _isBorrowingFacilities,
        'status': 'pending', // Status awal: Menunggu Persetujuan
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Berhasil 🎉"),
            content: const Text("Permintaan peminjaman telah dikirim ke Admin."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NAVIGASI BOTTOM BAR ---
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

  // Helper Fasilitas
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFormCard(),
            const SizedBox(height: 40),
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
        Text("Hi $_name !", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
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
                      validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel("Ruangan"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      hint: const Text("Pilih Ruangan"),
                      decoration: _inputDecoration(),
                      items: _roomList.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setState(() => _selectedRoom = v),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel("Waktu (Sesi)"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedSession,
                      hint: const Text("Pilih Sesi"),
                      decoration: _inputDecoration(),
                      items: _sessionList.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _selectedSession = v),
                      validator: (val) => val == null ? "Wajib dipilih" : null,
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

                    // Tampilkan jika switch ON
                    if (_isBorrowingFacilities) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInputLabel("Fasilitas"),
                          InkWell(
                            onTap: _addFacility,
                            child: const Row(children: [Icon(Icons.add_circle, size: 16), SizedBox(width: 4), Text("Tambah Alat", style: TextStyle(fontWeight: FontWeight.bold))]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFacilities.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedFacilities[index]['name'],
                                    isDense: true,
                                    decoration: _inputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                                    items: _facilityOptions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                                    onChanged: (v) => setState(() => _selectedFacilities[index]['name'] = v),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: _selectedFacilities[index]['qty'].toString(),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: _inputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                                    onChanged: (v) => _selectedFacilities[index]['qty'] = int.tryParse(v) ?? 1,
                                  ),
                                ),
                                if (_selectedFacilities.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () => _removeFacility(index),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 30),
                    const Text("Dengan ini saya akan mengikuti seluruh aturan yang berlaku sebagai mana yang telah terlampir pada halaman Aturan !!!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.justify),
                    const SizedBox(height: 30),

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
                            backgroundColor: Colors.white, foregroundColor: Colors.black,
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

  // Helpers
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
      filled: true, fillColor: inputFillColor,
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
            BottomNavigationBarItem(label: "", icon: Container(width: 50, height: 50, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black), child: const Icon(Icons.add, color: Colors.white, size: 30))),
            const BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: "Notification", activeIcon: Icon(Icons.notifications)),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile", activeIcon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
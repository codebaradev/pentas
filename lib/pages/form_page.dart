import 'package:flutter/material.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/jadwal_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'package:pentas/service/auth_service.dart';

class FormPeminjamanPage extends StatefulWidget {
  const FormPeminjamanPage({super.key});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final AuthService _authService = AuthService();
  String _name = "Memuat...";
  String _nim = "Memuat...";
  String _status = "Memuat...";

  int _selectedIndex = 2;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whatsappController = TextEditingController(text: "085342614904");
  
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

  bool _isBorrowingFacilities = true;

  List<Map<String, dynamic>> _selectedFacilities = [
    {'name': 'Proyektor', 'qty': 1} // Default item pertama
  ];

  final List<String> _facilityOptions = [
    "Proyektor",
    "Terminal Kabel",
    "HDMI Kabel",
    "Spidol",
    "Lainnya"
  ];

  final Color cardColor = const Color(0xFFF9A887); // Oranye Terang
  final Color cardHeaderColor = const Color(0xFFC06035); // Coklat/Oranye Gelap (Header)
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color inputFillColor = const Color(0xFFFFE0D6); // Warna input field

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDetails = await _authService.getUserDetails();
    if (mounted && userDetails != null) {
      setState(() {
        _name = userDetails['name']?.toString() ?? 'Data tidak ditemukan';
        _nim = userDetails['nim']?.toString() ?? 'Data tidak ditemukan';
        _status = userDetails['role']?.toString() ?? 'Data tidak ditemukan';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
        // Pindah ke Halaman Jadwal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JadwalPage()),
        );
        return;
    } 
    else if (index == 3) {
        // Pindah ke Halaman Notifikasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        return;
    }
    else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
    // TODO: Index 3 (Notification
  }

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
        title: const Text(
          "Peminjaman", // Judul AppBar sesuai gambar
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Form Card Utama
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
        Text(
          "Hi $_name!",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, // Latar oranye terang
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: Colors.black, width: 1), // Opsional: border hitam tipis
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header Form "Form Peminjaman"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: cardHeaderColor, // Warna Header Gelap
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

            // Isi Form
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data Diri (Statis)
                    _buildStaticInfoRow("Nama", _name),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("NIM", _nim),
                    const SizedBox(height: 12),
                    _buildStaticInfoRow("Status", _status),
                    
                    const SizedBox(height: 20),

                    // Input WhatsApp
                    _buildInputLabel("WhatsApp"),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(),
                    ),

                    const SizedBox(height: 16),

                    // Dropdown Ruangan
                    _buildInputLabel("Ruangan"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      hint: const Text("Pilih Ruangan"),
                      decoration: _inputDecoration(),
                      items: _roomList.map((String room) {
                        return DropdownMenuItem<String>(
                          value: room,
                          child: Text(room),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedRoom = newValue;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Dropdown Waktu Sesi
                    _buildInputLabel("Waktu"),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedSession,
                      hint: const Text("Pilih Sesi Waktu"),
                      decoration: _inputDecoration(),
                      items: _sessionList.map((String session) {
                        return DropdownMenuItem<String>(
                          value: session,
                          child: Text(session),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSession = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Sesi waktu tidak boleh kosong' : null,
                    ),

                    const SizedBox(height: 16),

                    // Switch untuk meminjam fasilitas
                    _buildToggleFacility(),

                    // --- BAGIAN FASILITAS (IMPROVISASI) ---
                    if (_isBorrowingFacilities)
                      _buildFacilitySection(),
                    // ---------------------------------------

                    const SizedBox(height: 30),

                    // Disclaimer Text
                    const Text(
                      "Dengan ini saya akan mengikuti seluruh aturan yang berlaku sebagai mana yang telah terlampir pada halaman Aturan !!!",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 30),

                    // Tombol Aksi (Batal & Submit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Tombol Batal (TextButton / OutlinedButton)
                        TextButton(
                          onPressed: () {
                            // Aksi Batal: Kembali ke halaman sebelumnya
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        
                        const SizedBox(width: 8),

                        // Tombol Submit (ElevatedButton Putih)
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Proses Submit Data
                              print("Submit: Room $_selectedRoom");
                              print("Submit: Session $_selectedSession");
                              if (_isBorrowingFacilities) {
                                print("Fasilitas: $_selectedFacilities");
                              } else {
                                print("Tidak meminjam fasilitas.");
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Peminjaman Berhasil Diajukan!")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Latar Putih
                            foregroundColor: Colors.black, // Teks Hitam
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildToggleFacility() {
    return SwitchListTile(
      title: const Text(
        "Pinjam Fasilitas Tambahan",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: _isBorrowingFacilities,
      onChanged: (bool value) {
        setState(() {
          _isBorrowingFacilities = value;
        });
      },
      activeColor: cardHeaderColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFacilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel("Fasilitas"),
            // Tombol Tambah Fasilitas Kecil
            InkWell(
              onTap: _addFacility,
              child: const Row(
                children: [
                  Icon(Icons.add_circle, size: 16, color: Colors.black87),
                  SizedBox(width: 4),
                  Text("Tambah Alat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // List Fasilitas Dinamis
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _selectedFacilities.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Dropdown Nama Alat (Flexible agar lebar)
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedFacilities[index]['name'],
                      isDense: true,
                      decoration: _inputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                      items: _facilityOptions.map((String facility) {
                        return DropdownMenuItem<String>(
                          value: facility,
                          child: Text(facility, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedFacilities[index]['name'] = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Input Jumlah (Kecil)
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: _selectedFacilities[index]['qty'].toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: _inputDecoration(contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                      onChanged: (val) {
                        _selectedFacilities[index]['qty'] = int.tryParse(val) ?? 1;
                      },
                    ),
                  ),

                  // Tombol Hapus (X) - Hanya muncul jika lebih dari 1 item
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
    );
  }

  Widget _buildStaticInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100, // Lebar label tetap agar sejajar
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // Helper: Label Input (WhatsApp :, Ruangan :, dll)
  Widget _buildInputLabel(String label) {
    return Row(
      children: [
        SizedBox(
          width: 100, 
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const Text(": ", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  InputDecoration _inputDecoration({EdgeInsetsGeometry? contentPadding}) {
    return InputDecoration(
      filled: true,
      fillColor: inputFillColor, // Warna pink muda/krem
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black54, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }

  // --- Bottom Nav Bar ---
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
          currentIndex: _selectedIndex, // Index 2 = Add/Form
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
                // Icon Plus yang aktif
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
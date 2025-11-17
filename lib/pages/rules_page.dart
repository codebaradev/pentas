import 'package:flutter/material.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/login_page.dart';

class PeraturanPage extends StatefulWidget {
  const PeraturanPage({super.key});

  @override
  State<PeraturanPage> createState() => _PeraturanPageState();
}

class _PeraturanPageState extends State<PeraturanPage> {
  // Index 1 adalah 'History' (sesuai desain Anda)
  int _selectedIndex = 1;

  // Controller untuk PageView
  late PageController _pageController;
  int _currentPageIndex = 0;

  // Judul untuk setiap halaman
  final List<String> _pageTitles = [
    "KETENTUAN UMUM",
    "LABORATORIUM KOMPUTER",
    "PEMINJAMAN PERALATAN",
    "PROSEDUR PENGEMBALIAN",
    "SANKSI DAN TANGGUNG JAWAB"
  ];

  // Warna kustom
  final Color cardColor = const Color(0xFFF9A887);
  final Color cardHeaderColor = const Color(0xFFD98B6A); // Oranye tua (header)
  final Color cardBackgroundColor = const Color(0xFFFFF0ED); // Oranye muda
  final Color pageBackgroundColor = const Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani klik Bottom Nav Bar (Sudah Benar)
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Sudah di halaman ini

    if (index == 0) {
      // Kembali ke Home
      Navigator.pop(context);
    } else if (index == 2) {
      // Tombol Add
      print("Tombol Add ditekan!");
      return;
    } else if (index == 4) {
      // Ganti ke Halaman Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else if (index == 3) {
      // Index 3 (Notification) tidak melakukan apa-apa.
      print("Tombol Notifikasi ditekan (tidak ada aksi).");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Aturan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparan agar menyatu
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            // 1. Header "Hi Dasmae" (Sama seperti Home)
            _buildWelcomeHeader(),
            const SizedBox(height: 24),

            // --- DESAIN BARU SLIDER ---
            
            // 2. PageView (Slider)
            _buildPageView(),

            // 3. Kontrol Panah (Gaya baru)
            _buildPageIndicator(),
            
            // --- AKHIR DESAIN BARU ---
            
            const SizedBox(height: 20), // Spasi di bawah
          ],
        ),
      ),
      // 4. Bottom Navigation Bar Kustom
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- WIDGET HELPER ---

  // Header "Hi Dasmae" (Sama, tidak berubah)
  Widget _buildWelcomeHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi Dasmae !",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Jalani harimu dengan ceria.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Widget PageView untuk slider
  Widget _buildPageView() {
    // Memberi tinggi tetap agar PageView berfungsi
    return SizedBox(
      height: 480, // Sesuaikan tinggi ini jika perlu
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          // Halaman 1: Ketentuan Umum
          _buildRuleCardPage(
            title: _pageTitles[0],
            child: _buildPageKetentuanUmum(),
          ),
          // Halaman 2: Lab Komputer
          _buildRuleCardPage(
            title: _pageTitles[1],
            child: _buildPageLabKomputer(),
          ),
          // Halaman 3: Peminjaman Peralatan
          _buildRuleCardPage(
            title: _pageTitles[2],
            child: _buildPagePeralatan(),
          ),
          // Halaman 4: Prosedur Pengembalian
          _buildRuleCardPage(
            title: _pageTitles[3],
            child: _buildPageProsedur(),
          ),
          // Halaman 5: Sanksi
          _buildRuleCardPage(
            title: _pageTitles[4],
            child: _buildPageSanksi(),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD BARU ---
  // Helper untuk membuat seluruh card oranye sesuai desain baru
  Widget _buildRuleCardPage({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), // Beri sedikit spasi
      decoration: BoxDecoration(
        color: cardBackgroundColor, // Warna oranye muda
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header "KETENTUAN UMUM", dll.
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: cardHeaderColor, // Warna oranye tua
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Konten (child)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                // Gunakan SingleChildScrollView agar konten di dalam card
                // bisa di-scroll jika tidak muat di layar kecil
                child: SingleChildScrollView(child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // --- PERBAIKAN DESAIN ITEM ATURAN ---
  // Helper untuk membuat item peraturan (Peminjam, Tujuan, dll.)
  Widget _buildRuleItem(String title, String content) {
    // Desain baru menggunakan teks rata tengah
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan
      children: [
        Text(
          title,
          textAlign: TextAlign.center, // Pusatkan
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          textAlign: TextAlign.center, // Pusatkan
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4, // Jarak antar baris
          ),
        ),
      ],
    );
  }

  // --- KONTEN SLIDER (Tidak diubah, hanya dipanggil) ---

  // Halaman 1: Konten Ketentuan Umum
  Widget _buildPageKetentuanUmum() {
    return Column(
      children: [
        _buildRuleItem(
          "Peminjam",
          "Peminjaman hanya dapat dilakukan oleh civitas akademika (mahasiswa, dosen, atau staf) yang terdaftar dan aktif.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Tujuan",
          "Fasilitas dan peralatan hanya boleh digunakan untuk kegiatan akademik, organisasi kemahasiswaan, atau kegiatan lain yang telah disetujui oleh pihak kampus.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Tanggung Jawab",
          "Peminjam bertanggung jawab penuh atas keutuhan, kebersihan, dan keamanan fasilitas atau peralatan yang dipinjam selama masa peminjaman.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Reservasi",
          "Peminjaman harus diajukan setidaknya 1x24 jam (H-1) sebelum waktu penggunaan melalui sistem PENTAS ITH atau petugas terkait.",
        ),
      ],
    );
  }

  // Halaman 2: Konten Lab Komputer
  Widget _buildPageLabKomputer() {
    return Column(
      children: [
        _buildRuleItem(
          "Larangan",
          "Dilarang keras membawa makanan dan minuman ke dalam area laboratorium.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Perangkat Lunak",
          "Dilarang menginstall perangkat lunak (software) atau game apapun tanpa izin dari petugas laboratorium.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Konfigurasi",
          "Dilarang mengubah pengaturan (setting) pada komputer, jaringan, atau sistem operasi.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Kondisi Akhir",
          "Setelah selesai digunakan, komputer harus dimatikan (Shut Down) dengan benar dan kursi dirapikan kembali ke posisi semula.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Data",
          "Pihak pengelola tidak bertanggung jawab atas kehilangan data pribadi yang disimpan di komputer laboratorium.",
        ),
      ],
    );
  }

  // Halaman 3: Konten Peminjaman Peralatan
  Widget _buildPagePeralatan() {
    return Column(
      children: [
        _buildRuleItem(
          "Pengecekan Awal",
          "Peminjam wajib memeriksa kondisi dan kelengkapan peralatan (termasuk fungsi proyektor dan kelengkapan kabel) bersama petugas saat serah terima.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Lapor Kerusakan",
          "Jika ditemukan kerusakan saat pengecekan awal, peminjam wajib langsung melapor kepada petugas. Kerusakan yang tidak dilaporkan di awal akan dianggap sebagai tanggung jawab peminjam.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Spidol",
          "Spidol harus dikembalikan dalam kondisi tertutup rapat untuk mencegah kering.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Kabel",
          "Semua kabel (HDMI, Terminal) harus digulung dengan rapi saat dikembalikan.",
        ),
      ],
    );
  }

  // Halaman 4: Konten Prosedur Pengembalian
  Widget _buildPageProsedur() {
    return Column(
      children: [
        _buildRuleItem(
          "Tepat Waktu",
          "Peralatan harus dikembalikan sesuai dengan batas waktu peminjaman yang telah disepakati.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Kondisi Pengembalian",
          "Peralatan harus dikembalikan dalam kondisi utuh, bersih, dan berfungsi normal seperti saat dipinjam.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Pengecekan Akhir",
          "Petugas akan melakukan pengecekan ulang kondisi barang saat dikembalikan.",
        ),
      ],
    );
  }
  
  // Halaman 5: Konten Sanksi
  Widget _buildPageSanksi() {
    return Column(
      children: [
        _buildRuleItem(
          "Kerusakan",
          "Peminjam wajib memperbaiki atau mengganti peralatan yang rusak akibat kelalaian selama masa peminjaman.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Kehilangan",
          "Peminjam wajib mengganti peralatan yang hilang dengan barang yang memiliki spesifikasi sama atau setara.",
        ),
        const SizedBox(height: 16),
        _buildRuleItem(
          "Keterlambatan",
          "Keterlambatan pengembalian tanpa konfirmasi akan dikenakan sanksi administratif, seperti penangguhan (skorsing) hak peminjaman.",
        ),
      ],
    );
  }

  // --- PERBAIKAN DESAIN PANAH NAVIGASI ---
  // Widget panah navigasi gaya baru
  Widget _buildPageIndicator() {
    // Tombol Panah Kustom
    Widget arrowButton({
      required IconData icon,
      required VoidCallback? onPressed,
      bool isVisible = true,
    }) {
      return Container(
        width: 40,
        height: 40,
        // Jika tidak terlihat, buat transparan
        color: isVisible ? Colors.transparent : Colors.transparent,
        child: isVisible // Hanya tampilkan jika isVisible == true
            ? Material(
                color: Colors.black,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onPressed,
                  customBorder: const CircleBorder(),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              )
            : null, // Jika tidak, jangan tampilkan apa-apa
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Tombol Kembali (Mundur)
        arrowButton(
          icon: Icons.arrow_back_ios_new_rounded,
          // Sembunyikan jika di halaman pertama
          isVisible: _currentPageIndex > 0,
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),

        // Tombol Maju
        arrowButton(
          icon: Icons.arrow_forward_ios_rounded,
          // Sembunyikan jika di halaman terakhir
          isVisible: _currentPageIndex < _pageTitles.length - 1,
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }


  // --- WIDGET BOTTOM NAV (Tidak Berubah) ---
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
          currentIndex: _selectedIndex, // <-- Ini penting (index 1)
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
              label: "Jadwal", // Mengganti label "History"
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
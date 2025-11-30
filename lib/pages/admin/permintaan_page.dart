import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PermintaanPage extends StatefulWidget {
  const PermintaanPage({super.key});

  @override
  State<PermintaanPage> createState() => _PermintaanPageState();

}

class _PermintaanPageState extends State<PermintaanPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Warna Tema Admin
  final Color primaryColor = const Color(0xFF526D9D);
  final Color cardColor = const Color(0xFFC8D6F5); 
  final Color approveColor = const Color(0xFF98FB98); 
  final Color rejectColor = const Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- FUNGSI UPDATE STATUS DI FIREBASE ---
  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('requests').doc(docId).update({
      'status': newStatus,
    });

    String message = newStatus == 'accepted' ? "Permintaan Disetujui" : "Permintaan Ditolak";
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Permintaan Masuk"),
        backgroundColor: primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Baru"),
            Tab(text: "Disetujui"),
            Tab(text: "Ditolak"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestStream("pending"),  // Tab 1: Menunggu
          _buildRequestStream("accepted"), // Tab 2: Diterima
          _buildRequestStream("rejected"), // Tab 3: Ditolak
        ],
      ),
    );
  }

  // --- WIDGET STREAM DARI FIREBASE ---
  Widget _buildRequestStream(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      // Query realtime: Ambil 'requests' dimana status == filter tab
      // Urutkan dari yang terbaru (createdAt descending)
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: statusFilter)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Error
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // 3. Data Kosong
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "Tidak ada data $statusFilter",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // 4. Ada Data -> Tampilkan List
        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id; // ID Dokumen untuk update nanti

            return _buildRequestCard(data, docId);
          },
        );
      },
    );
  }

  // --- WIDGET KARTU PERMINTAAN ---
  Widget _buildRequestCard(Map<String, dynamic> item, String docId) {
    bool isPending = item['status'] == 'pending';
    
    // Parsing data dengan nilai default (mencegah error null)
    String name = item['name'] ?? 'Tanpa Nama';
    String nim = item['nim'] ?? '-';
    String role = item['role'] ?? '-';
    String whatsapp = item['whatsapp'] ?? '-';
    String room = item['room'] ?? '-';
    String session = item['session'] ?? '-';
    
    // Format teks sesi agar tidak kepanjangan (misal: "Sesi 1...")
    String shortSession = session.length > 6 ? session.substring(0, 6) : session;

    // Logic Tampilan Barang (Ruangan + Jumlah Alat)
    String itemDisplay = room;
    bool hasTools = item['hasTools'] ?? false;
    
    if (hasTools) {
      List<dynamic> tools = item['tools'] ?? [];
      if (tools.isNotEmpty) {
        // Contoh tampilan: "Ruang 201 (+ 2 Alat)"
        itemDisplay = "$room (+ ${tools.length} Alat)";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Card (Nama & Role) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$role • $nim",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
                // Badge Status (Jika bukan pending)
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: item['status'] == 'accepted' ? approveColor : rejectColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Text(
                      item['status'] == 'accepted' ? "Disetujui" : "Ditolak",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 24),

            // --- Detail Peminjaman ---
            Row(
              children: [
                Expanded(child: _buildInfoColumn("Peminjaman", itemDisplay)),
                _buildInfoColumn("Sesi", shortSession),
                Expanded(child: _buildInfoColumn("Kontak", whatsapp)),
              ],
            ),

            // --- Tombol Aksi (Hanya Muncul di Tab Baru/Pending) ---
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // Tombol Terima
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(name, itemDisplay, docId, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: approveColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text("Terima"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Tolak
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(name, itemDisplay, docId, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rejectColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Text("Tolak"),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper untuk kolom info kecil
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  // --- DIALOG KONFIRMASI ---
  void _showConfirmDialog(String name, String item, String docId, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'accepted' ? "Terima Permintaan?" : "Tolak Permintaan?"),
        content: Text(
          "Anda akan ${action == 'accepted' ? 'menyetujui' : 'menolak'} peminjaman $item oleh $name.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _updateStatus(docId, action); // Jalankan update ke Firebase
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }
  
}
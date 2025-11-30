import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Untuk fitur copy text
import 'package:intl/intl.dart';

class PermintaanPage extends StatefulWidget {
  const PermintaanPage({super.key});

  @override
  State<PermintaanPage> createState() => _PermintaanPageState();
}

class _PermintaanPageState extends State<PermintaanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Palet Warna Modern
  final Color primaryColor = const Color(0xFF526D9D);
  final Color backgroundColor = const Color(0xFFF5F7FA); // Abu-abu sangat muda
  final Color pendingColor = const Color(0xFFFFA726); // Oranye
  final Color successColor = const Color(0xFF66BB6A); // Hijau
  final Color errorColor = const Color(0xFFEF5350);   // Merah

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

  // Update Firebase
  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('requests').doc(docId).update({
      'status': newStatus,
    });

    String message = newStatus == 'accepted' ? "Permintaan Disetujui ✅" : "Permintaan Ditolak ❌";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: newStatus == 'accepted' ? successColor : errorColor,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Manajemen Permintaan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Baru", icon: Icon(Icons.access_time)),
            Tab(text: "Disetujui", icon: Icon(Icons.check_circle_outline)),
            Tab(text: "Ditolak", icon: Icon(Icons.cancel_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestStream("pending"),
          _buildRequestStream("accepted"),
          _buildRequestStream("rejected"),
        ],
      ),
    );
  }

  Widget _buildRequestStream(String statusFilter) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: statusFilter)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;

            return _buildRequestCard(data, docId);
          },
        );
      },
    );
  }

  // --- UI KARTU PERMINTAAN ---
  Widget _buildRequestCard(Map<String, dynamic> item, String docId) {
    bool isPending = item['status'] == 'pending';
    
    // Data Parsing
    String name = item['name'] ?? 'Tanpa Nama';
    String nim = item['nim'] ?? '-';
    String role = item['role'] ?? '-';
    String whatsapp = item['whatsapp'] ?? '-';
    String room = item['room'] ?? '-';
    String session = item['session'] ?? '-';
    String shortSession = session.length > 6 ? session.substring(0, 6) : session;

    // Parsing Tanggal
    Timestamp? dateTimestamp = item['date'] as Timestamp?;
    String formattedDate = 'Tanpa Tanggal';
    if (dateTimestamp != null) {
      DateTime date = dateTimestamp.toDate();
      // Pastikan locale 'id_ID' sudah diregistrasi di main.dart
      formattedDate = DateFormat('EEEE, d MMM y', 'id_ID').format(date);
    }

    // Deteksi tipe peminjaman (Ruangan atau Alat)
    bool hasTools = item['hasTools'] ?? false;
    String itemTitle = room;
    String itemSubtitle = "Fasilitas Ruangan";
    IconData itemIcon = Icons.meeting_room;

    if (hasTools) {
      List<dynamic> tools = item['tools'] ?? [];
      if (tools.isNotEmpty) {
        String firstTool = tools[0]['name'];
        int toolCount = tools.length;
        itemTitle = "$room + $firstTool";
        if (toolCount > 1) itemTitle += " (+${toolCount - 1})";
        itemSubtitle = "Ruangan & Alat";
        itemIcon = Icons.devices_other;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // 1. Header: Info Peminjam
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("$role • $nim", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                // Fitur Copy WA
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                  tooltip: "Salin No WA",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: whatsapp));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nomor WhatsApp disalin!"), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. Body: Detail Peminjaman
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ikon Besar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(itemIcon, color: primaryColor, size: 32),
                ),
                const SizedBox(width: 16),
                // Detail Teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(formattedDate, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text("Sesi: $shortSession", style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(itemSubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Footer: Tombol Aksi / Status
          if (isPending) 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showConfirmDialog(name, itemTitle, docId, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Tolak"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(color: errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmDialog(name, itemTitle, docId, 'accepted'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Terima"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: item['status'] == 'accepted' ? successColor.withOpacity(0.1) : errorColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Center(
                child: Text(
                  item['status'] == 'accepted' ? "PERMINTAAN DISETUJUI" : "PERMINTAAN DITOLAK",
                  style: TextStyle(
                    color: item['status'] == 'accepted' ? successColor : errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState(String status) {
    String message = "";
    IconData icon = Icons.inbox;

    if (status == 'pending') {
      message = "Tidak ada permintaan baru";
      icon = Icons.mark_email_read_outlined;
    } else if (status == 'accepted') {
      message = "Belum ada yang disetujui";
      icon = Icons.check_circle_outline;
    } else {
      message = "Belum ada yang ditolak";
      icon = Icons.highlight_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  // --- Dialog Konfirmasi ---
  void _showConfirmDialog(String name, String item, String docId, String action) {
    bool isApprove = action == 'accepted';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(isApprove ? Icons.check_circle : Icons.cancel, color: isApprove ? successColor : errorColor),
            const SizedBox(width: 10),
            Text(isApprove ? "Terima?" : "Tolak?"),
          ],
        ),
        content: Text.rich(
          TextSpan(
            text: "Anda akan ",
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                text: isApprove ? "menyetujui" : "menolak",
                style: TextStyle(fontWeight: FontWeight.bold, color: isApprove ? successColor : errorColor),
              ),
              const TextSpan(text: " peminjaman:\n\n"),
              TextSpan(text: item, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: "\noleh "),
              TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(docId, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? successColor : errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Konfirmasi", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
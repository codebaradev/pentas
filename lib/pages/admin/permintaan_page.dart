import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pentas/service/firebase_service.dart';

class PermintaanPage extends StatefulWidget {
  const PermintaanPage({super.key});

  @override
  State<PermintaanPage> createState() => _PermintaanPageState();
}

class _PermintaanPageState extends State<PermintaanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _expiredScheduleTimer;
  final FirebaseService _firebaseService = FirebaseService();

  // Palet Warna Modern
  final Color primaryColor = const Color(0xFF526D9D);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color pendingColor = const Color(0xFFFFA726);
  final Color successColor = const Color(0xFF66BB6A);
  final Color errorColor = const Color(0xFFEF5350);
  final Color countdownColor = const Color(0xFFFF9800);
  final Color expiredColor = const Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Auto-check expired schedules setiap menit
    _checkExpiredSchedules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expiredScheduleTimer?.cancel();
    super.dispose();
  }

  // Auto-check for expired schedules
  void _checkExpiredSchedules() {
    _expiredScheduleTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _removeExpiredSchedules();
    });
  }

  // Remove expired schedules
  Future<void> _removeExpiredSchedules() async {
    try {
      final now = DateTime.now();
      
      // 1. Ambil semua request yang statusnya 'accepted'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .get();

      // 2. Ambil Mapping Nama Alat ke ID Dokumen (Tidak perlu ambil quantity disini)
      final toolsSnapshot = await FirebaseFirestore.instance.collection('tools').get();
      final Map<String, String> toolIds = {
        for (var doc in toolsSnapshot.docs)
          doc.data()['name']: doc.id // Map: Nama Alat -> ID Dokumen
      };

      // 3. Loop setiap request
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = data['date'] as Timestamp?;
        final session = data['session'] as String?;

        if (date != null && session != null) {
          final scheduleDate = date.toDate();
          final endTime = _parseSessionEndTime(session, scheduleDate);

          // Jika waktu sudah lewat 5 menit dari jadwal selesai
          if (now.isAfter(endTime.add(const Duration(minutes: 5)))) {
            
            // LOGIKA PENGEMBALIAN ALAT (FIXED)
            if (data['hasTools'] == true && data['tools'] != null) {
              List requestedTools = data['tools'];
              
              for (var requestedTool in requestedTools) {
                String toolName = requestedTool['name'];
                // Pastikan qty dibaca sebagai integer
                int requestedQty = int.parse(requestedTool['qty'].toString()); 

                // Jika nama alat ada di database tools
                if (toolIds.containsKey(toolName)) {
                  String toolId = toolIds[toolName]!;
                  
                  // MENGGUNAKAN FIELDVALUE.INCREMENT
                  // Ini langsung menambahkan jumlah ke database tanpa perlu baca stok lama
                  // Sangat aman untuk menghindari data bentrok
                  await FirebaseFirestore.instance
                      .collection('tools')
                      .doc(toolId)
                      .update({
                        'quantity': FieldValue.increment(requestedQty)
                      });
                      
                  print("Mengembalikan $requestedQty $toolName ke stok.");
                }
              }
            }

            // Hapus request setelah alat dikembalikan
            await FirebaseFirestore.instance
                .collection('requests')
                .doc(doc.id)
                .delete();
          }
        }
      }
    } catch (e) {
      print("Error removing expired schedules: $e");
    }
  }

  // Parse session end time
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

    // Default: 2 jam setelah schedule date
    return scheduleDate.add(const Duration(hours: 2));
  }

  // Calculate countdown for admin
  String _calculateCountdown(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return "Waktu Habis";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 24) {
      final days = difference.inDays;
      return "${days}h ${hours.remainder(24)}j";
    } else if (hours > 0) {
      return "${hours}j ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  // Update Firebase
    Future<void> _updateStatus(
    String docId,
    String newStatus,
    Map<String, dynamic> requestData,
  ) async {
    final String message = newStatus == 'accepted'
        ? "Peminjaman Ruangan di Setujui !"
        : "Peminjaman Ruangan di Tolak !";

    // 1) Jika disetujui & ada peminjaman alat → kurangi stok via FirebaseService
    if (newStatus == 'accepted' &&
        requestData['hasTools'] == true &&
        requestData['tools'] != null) {
      try {
        // pastikan bentuknya List<dynamic>
        final List<dynamic> tools =
            List<dynamic>.from(requestData['tools'] as List);

        // pakai helper yang sudah kamu buat di firebase_service.dart
        await _firebaseService.decreaseToolsStockForRequest(tools);
      } catch (e) {
        debugPrint("Error updating tools stock: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal memperbarui stok alat!"),
            backgroundColor: errorColor,
          ),
        );
        return; // jangan lanjut update status kalau stok gagal
      }
    }

    // 2) Update status request + notifikasi
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(docId)
          .update({
        'status': newStatus,
        'notificationMessage': message,
        'notificationRead': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'accepted'
                ? "Permintaan Disetujui ✅"
                : "Permintaan Ditolak ❌",
          ),
          backgroundColor:
              newStatus == 'accepted' ? successColor : errorColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint("Error update status request: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gagal mengubah status permintaan!"),
          backgroundColor: errorColor,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Manajemen Permintaan",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: statusFilter)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        final docs = snapshot.data!.docs;

        // Untuk tab "Disetujui", filter hanya jadwal hari ini dan kedepan
        List<QueryDocumentSnapshot> filteredDocs = docs;
        if (statusFilter == 'accepted') {
          filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] as Timestamp?;

            if (date != null) {
              final scheduleDate = date.toDate();
              return scheduleDate.isAtSameMomentAs(todayStart) ||
                  scheduleDate.isAfter(todayStart);
            }
            return false;
          }).toList();
        }

        if (filteredDocs.isEmpty) {
          return _buildEmptyState(statusFilter);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;

            return _buildRequestCard(data, docId, statusFilter);
          },
        );
      },
    );
  }

  // --- UI KARTU PERMINTAAN ---
  Widget _buildRequestCard(
      Map<String, dynamic> item, String docId, String statusFilter) {
    bool isPending = item['status'] == 'pending';
    bool isAccepted = item['status'] == 'accepted';

    // Data Parsing
    String name = item['name'] ?? 'Tanpa Nama';
    String nim = item['nim'] ?? '-';
    String role = item['role'] ?? '-';
    String whatsapp = item['whatsapp'] ?? '-';
    String room = item['room'] ?? '-';
    String session = item['session'] ?? '-';
    String shortSession =
        session.length > 6 ? session.substring(0, 6) : session;

    // Parsing Tanggal
    Timestamp? dateTimestamp = item['date'] as Timestamp?;
    String formattedDate = 'Tanpa Tanggal';
    DateTime? scheduleDate;
    DateTime? endTime;
    String countdownText = "";

    if (dateTimestamp != null) {
      scheduleDate = dateTimestamp.toDate();
      formattedDate =
          DateFormat('EEEE, d MMM y', 'id_ID').format(scheduleDate!);

      // Parse end time untuk countdown (hanya untuk yang disetujui)
      if (isAccepted && scheduleDate != null) {
        endTime = _parseSessionEndTime(session, scheduleDate!);
        countdownText = _calculateCountdown(endTime!);
      }
    }

    // Deteksi tipe peminjaman
    bool hasTools = item['hasTools'] ?? false;
    String itemTitle = room;
    String itemSubtitle = "Fasilitas Ruangan";
    IconData itemIcon = Icons.meeting_room;

    if (hasTools) {
      List<dynamic> tools = item['tools'] ?? [];
      if (tools.isNotEmpty) {
        final toolsSummary = tools
            .map((tool) =>
                "${tool['name'] ?? 'Alat tidak diketahui'} (x${tool['qty'] ?? 1})")
            .join(', ');
        itemTitle = "$room + $toolsSummary";
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("$role • $nim",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
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
                      const SnackBar(
                          content: Text("Nomor WhatsApp disalin!"),
                          duration: const Duration(seconds: 1)),
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
                      Text(itemTitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(formattedDate,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[800])),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text("Sesi: $shortSession",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[800])),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(itemSubtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),

                      // Countdown untuk jadwal yang disetujui
                      if (isAccepted && endTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: countdownText == "Waktu Habis"
                                  ? expiredColor.withOpacity(0.1)
                                  : countdownColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: countdownText == "Waktu Habis"
                                    ? expiredColor
                                    : countdownColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 12,
                                  color: countdownText == "Waktu Habis"
                                      ? expiredColor
                                      : countdownColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  countdownText,
                                  style: TextStyle(
                                    color: countdownText == "Waktu Habis"
                                        ? expiredColor
                                        : countdownColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                      onPressed: () => _showConfirmDialog(
                          name, itemTitle, docId, item, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Tolak"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(color: errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmDialog(
                          name, itemTitle, docId, item, 'accepted'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Terima"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                color: isAccepted
                    ? successColor.withOpacity(0.1)
                    : errorColor.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Center(
                child: Text(
                  isAccepted
                      ? "PERMINTAAN DISETUJUI"
                      : "PERMINTAAN DITOLAK",
                  style: TextStyle(
                    color: isAccepted ? successColor : errorColor,
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
      message = "Tidak ada jadwal yang sedang berlangsung";
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
          Text(message,
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }

  // --- Dialog Konfirmasi ---
  void _showConfirmDialog(String name, String item, String docId,
      Map<String, dynamic> requestData, String action) {
    bool isApprove = action == 'accepted';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(isApprove ? Icons.check_circle : Icons.cancel,
                color: isApprove ? successColor : errorColor),
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
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isApprove ? successColor : errorColor),
              ),
              const TextSpan(text: " peminjaman:\n\n"),
              TextSpan(
                  text: item,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: "\noleh "),
              TextSpan(
                  text: name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
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
              _updateStatus(docId, action, requestData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? successColor : errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Konfirmasi",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

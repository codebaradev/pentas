import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pentas/service/firebase_service.dart';

class RequestManagementPage extends StatefulWidget {
  const RequestManagementPage({super.key});

  @override
  State<RequestManagementPage> createState() => _RequestManagementPageState();
}

class _RequestManagementPageState extends State<RequestManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text(
            "Manajemen Permintaan",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Baru"),
              Tab(text: "Disetujui"),
              Tab(text: "Ditolak"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestList(status: 'pending'),
            _RequestList(status: 'accepted'),
            _RequestList(status: 'rejected'),
          ],
        ),
      ),
    );
  }
}

// -------------------- LIST PERMINTAAN --------------------

class _RequestList extends StatelessWidget {
  final String status;
  const _RequestList({required this.status});

  Color get _statusColor {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'accepted':
        return "Disetujui";
      case 'rejected':
        return "Ditolak";
      default:
        return "Baru";
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final firebaseService = FirebaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('requests')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Terjadi kesalahan mengambil data"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "Tidak ada permintaan $_statusLabel",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final name = data['name'] ?? '-';
            final role = data['role'] ?? '-';
            final nim = data['nim'] ?? '-';
            final room = data['room'] ?? '-';
            final session = data['session'] ?? '-';
            final date = (data['date'] as Timestamp?)?.toDate();
            final hasTools = data['hasTools'] ?? false;
            final tools = (data['tools'] ?? []) as List<dynamic>;

            String dateStr = '-';
            if (date != null) {
              dateStr = DateFormat('EEEE, d MMM y', 'id_ID').format(date);
            }

            String toolsSummary = "Tidak ada alat tambahan";
            if (hasTools && tools.isNotEmpty) {
              final temp = <String>[];
              for (final t in tools) {
                if (t is Map) {
                  final map = Map<String, dynamic>.from(t);
                  final String? toolName = map['name'] as String?;
                  final int qty = (map['qty'] as int?) ?? 0;
                  if (toolName != null && toolName.isNotEmpty && qty > 0) {
                    temp.add("$toolName (x$qty)");
                  }
                }
              }
              if (temp.isNotEmpty) {
                toolsSummary = temp.join(", ");
              }
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header nama + status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(
                                "$role • $nim",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "$room + $toolsSummary",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "Sesi: $session",
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    if (status == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                              onPressed: () async {
                                try {
                                  await doc.reference.update({
                                    'status': 'rejected',
                                    'notificationRead': false,
                                    'notificationMessage':
                                        'Permintaan Anda ditolak.',
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Permintaan berhasil ditolak."),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Gagal menolak permintaan: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Tolak",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                try {
                                  // Kurangi stok alat kalau ada
                                  if (hasTools && tools.isNotEmpty) {
                                    await firebaseService
                                        .decreaseToolsStockForRequest(tools);
                                  }

                                  await doc.reference.update({
                                    'status': 'accepted',
                                    'notificationRead': false,
                                    'notificationMessage':
                                        'Permintaan Anda telah disetujui.',
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Permintaan berhasil disetujui."),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Gagal memperbarui stok alat: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Terima",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

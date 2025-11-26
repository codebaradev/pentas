import 'package:flutter/material.dart';

class PermintaanPage extends StatefulWidget {
  const PermintaanPage({super.key});

  @override
  State<PermintaanPage> createState() => _PermintaanPageState();

}

class _PermintaanPageState extends State<PermintaanPage> with TickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryColor = const Color(0xFF526D9D);
  final Color cardColor = const Color(0xFFC8D6F5); // Biru Muda
  final Color approveColor = const Color(0xFF98FB98); // Hijau Muda (Terima)
  final Color rejectColor = const Color(0xFFFF6B6B);

  final List<Map<String, dynamic>> _requests = [
    {
      "id": "1",
      "name": "Aditya Septiawan",
      "nim": "231011135",
      "role": "Mahasiswa",
      "whatsapp": "085342614904",
      "item": "LAB 203",
      "qty": 1,
      "status": "pending", // pending, accepted, rejected
    },
    {
      "id": "2",
      "name": "Papa Zola",
      "nim": "-",
      "role": "Dosen",
      "whatsapp": "085342614912",
      "item": "LAB 201",
      "qty": 1,
      "status": "pending",
    },
    {
      "id": "3",
      "name": "Fahrul Reynaldi",
      "nim": "-",
      "role": "Dosen",
      "whatsapp": "085342614913",
      "item": "Projektor",
      "qty": 1,
      "status": "accepted",
    },
    {
      "id": "4",
      "name": "Ahmeng",
      "nim": "231011101",
      "role": "Mahasiswa",
      "whatsapp": "085342614914",
      "item": "HDMI Cable",
      "qty": 2,
      "status": "rejected",
    },
  ];

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

  void _updateStatus(String id, String newStatus) {
    setState(() {
      final index = _requests.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        _requests[index]['status'] = newStatus;
      }
    });
    
    String message = newStatus == 'accepted' ? "Permintaan Diterima" : "Permintaan Ditolak";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
      duration: const Duration(seconds: 1),
    ));
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
          _buildRequestList("pending"),
          _buildRequestList("accepted"),
          _buildRequestList("rejected"),
        ],
      ),
    );
  }

  Widget _buildRequestList(String statusFilter) {
    // Filter data sesuai tab
    final filteredList = _requests.where((item) => item['status'] == statusFilter).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Tidak ada permintaan $statusFilter",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return _buildRequestCard(item);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> item) {
    bool isPending = item['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.3), // Warna biru sangat muda
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card: Nama & Role
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${item['role']} • ${item['nim']}",
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
                      item['status'] == 'accepted' ? "On Air" : "Ditolak",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 24),

            // Detail Peminjaman
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn("Barang/Ruang", item['item']),
                ),
                _buildInfoColumn("Jumlah", "${item['qty']} Unit"),
                Expanded(
                  child: _buildInfoColumn("Kontak", item['whatsapp']),
                ),
              ],
            ),

            // Tombol Aksi (Hanya untuk Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(item, 'accepted'),
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmDialog(item, 'rejected'),
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

  // Dialog Konfirmasi
  void _showConfirmDialog(Map<String, dynamic> item, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'accepted' ? "Terima Permintaan?" : "Tolak Permintaan?"),
        content: Text(
          "Anda akan ${action == 'accepted' ? 'menyetujui' : 'menolak'} peminjaman ${item['item']} oleh ${item['name']}.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(item['id'], action);
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }
  
}
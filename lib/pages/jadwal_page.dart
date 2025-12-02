import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/profile_page.dart';
import 'package:pentas/pages/form_page.dart';
import 'package:pentas/pages/notification_page.dart';
import 'dart:async';

class _CountdownWidget extends StatefulWidget {
  final DateTime endTime;
  final Color countdownColor;
  final Color expiredColor;

  const _CountdownWidget({
    super.key,
    required this.endTime,
    required this.countdownColor,
    required this.expiredColor,
  });

  @override
  State<_CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<_CountdownWidget> {
  late Timer _timer;
  late String _countdownText;

  @override
  void initState() {
    super.initState();
    _countdownText = _calculateCountdown(widget.endTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final newText = _calculateCountdown(widget.endTime);
        if (newText != _countdownText) {
          setState(() {
            _countdownText = newText;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _calculateCountdown(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      if (_timer.isActive) {
        _timer.cancel();
      }
      return "Waktu Habis";
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}j ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.countdownColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: widget.countdownColor,
          ),
          const SizedBox(width: 4),
          Text(
            _countdownText,
            style: TextStyle(
              color: _countdownText == "Waktu Habis"
                  ? widget.expiredColor
                  : widget.countdownColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  String _username = "Pengguna";
  String _userId = "";
  late TabController _tabController;
  Timer? _countdownTimer;

  final Color pageBackgroundColor = const Color(0xFFFAFAFA);
  final Color headerDarkColor = const Color(0xFF2A2A2A);
  final Color rowLightColor = const Color(0xFFE0E0E0);
  final Color myScheduleColor = const Color(0xFF4CAF50);
  final Color countdownColor = const Color(0xFFFF9800);
  final Color expiredColor = const Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists && mounted) {
          setState(() {
            _username = userDoc.get('name') ?? "Pengguna";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Helper: Get current date at 00:00:00
  DateTime getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Helper: Parse session time to DateTime
  Map<String, dynamic> parseSessionTime(String session, DateTime scheduleDate) {
    try {
      // Format: "Sesi 1: 07.00-08.40"
      if (session.contains(':') && session.contains('-')) {
        final parts = session.split(':');
        if (parts.length > 1) {
          final timePart = parts[1].trim();
          final timeRange = timePart.split('-');
          if (timeRange.length == 2) {
            final startTimeStr = timeRange[0].trim();
            final endTimeStr = timeRange[1].trim();
            
            // Parse start time
            final startParts = startTimeStr.split('.');
            if (startParts.length == 2) {
              final startHour = int.parse(startParts[0]);
              final startMinute = int.parse(startParts[1]);
              
              final startDateTime = DateTime(
                scheduleDate.year,
                scheduleDate.month,
                scheduleDate.day,
                startHour,
                startMinute,
              );
              
              // Parse end time
              final endParts = endTimeStr.split('.');
              if (endParts.length == 2) {
                final endHour = int.parse(endParts[0]);
                final endMinute = int.parse(endParts[1]);
                
                final endDateTime = DateTime(
                  scheduleDate.year,
                  scheduleDate.month,
                  scheduleDate.day,
                  endHour,
                  endMinute,
                );
                
                return {
                  'start': startDateTime,
                  'end': endDateTime,
                  'startStr': startTimeStr,
                  'endStr': endTimeStr,
                };
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error parsing session time: $e");
    }
    
    // Default fallback
    return {
      'start': scheduleDate,
      'end': scheduleDate.add(const Duration(hours: 2)),
      'startStr': '00:00',
      'endStr': '02:00',
    };
  }

  // Helper: Check if schedule is upcoming or ongoing
  String getScheduleStatus(Map<String, dynamic> timeInfo) {
    final now = DateTime.now();
    final start = timeInfo['start'] as DateTime;
    final end = timeInfo['end'] as DateTime;
    
    if (now.isBefore(start)) {
      return "Akan Datang";
    } else if (now.isAfter(start) && now.isBefore(end)) {
      return "Sedang Berlangsung";
    } else {
      return "Selesai";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Akan Datang":
        return Colors.blue;
      case "Sedang Berlangsung":
        return Colors.green;
      case "Selesai":
        return Colors.grey;
      default:
        return Colors.black;
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
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FormPeminjamanPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotificationPage()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Jadwal",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi $_username!",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Berikut jadwal peminjaman laboratorium",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: headerDarkColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF9A887),
                  ),
                  tabs: const [
                    Tab(text: "Semua Jadwal"),
                    Tab(text: "Jadwal Saya"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Content - Gunakan Expanded agar tidak overflow
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Semua Jadwal yang sudah di-acc
                  _buildAllScheduleContent(),
                  // Tab 2: Jadwal saya saja
                  _buildMyScheduleContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildAllScheduleContent() {
    final todayStart = getTodayStart();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .orderBy('date')
          .orderBy('session')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Belum ada jadwal yang disetujui");
        }

        final docs = snapshot.data!.docs;

        // Filter: hanya tanggal hari ini dan kedepan
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as Timestamp?;
          
          if (date != null) {
            final scheduleDate = date.toDate();
            // Hanya tampilkan jika tanggal >= hari ini
            return scheduleDate.isAtSameMomentAs(todayStart) || 
                   scheduleDate.isAfter(todayStart);
          }
          return false;
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState("Tidak ada jadwal untuk hari ini dan seterusnya");
        }

        // Kelompokkan berdasarkan tanggal
        Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};
        
        for (var doc in filteredDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as Timestamp?;
          
          if (date != null) {
            final dateStr = DateFormat('yyyy-MM-dd').format(date.toDate());
            
            if (!groupedByDate.containsKey(dateStr)) {
              groupedByDate[dateStr] = [];
            }
            groupedByDate[dateStr]!.add(doc);
          }
        }

        // Sort tanggal
        final sortedDates = groupedByDate.keys.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              for (var dateStr in sortedDates)
                _buildDateScheduleCard(
                  dateStr: dateStr,
                  schedules: groupedByDate[dateStr]!,
                  isMySchedule: false,
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyScheduleContent() {
    if (_userId.isEmpty) {
      return _buildLoadingState();
    }

    final todayStart = getTodayStart();
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: _userId)
          .where('status', isEqualTo: 'accepted')
          .orderBy('date')
          .orderBy('session')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Anda belum memiliki jadwal yang disetujui");
        }

        final docs = snapshot.data!.docs;

        // Filter: hanya tanggal hari ini dan kedepan
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as Timestamp?;
          
          if (date != null) {
            final scheduleDate = date.toDate();
            // Hanya tampilkan jika tanggal >= hari ini
            return scheduleDate.isAtSameMomentAs(todayStart) || 
                   scheduleDate.isAfter(todayStart);
          }
          return false;
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState("Tidak ada jadwal Anda untuk hari ini dan seterusnya");
        }

        // Kelompokkan berdasarkan tanggal
        Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};
        
        for (var doc in filteredDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as Timestamp?;
          
          if (date != null) {
            final dateStr = DateFormat('yyyy-MM-dd').format(date.toDate());
            
            if (!groupedByDate.containsKey(dateStr)) {
              groupedByDate[dateStr] = [];
            }
            groupedByDate[dateStr]!.add(doc);
          }
        }

        // Sort tanggal
        final sortedDates = groupedByDate.keys.toList()..sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              for (var dateStr in sortedDates)
                _buildDateScheduleCard(
                  dateStr: dateStr,
                  schedules: groupedByDate[dateStr]!,
                  isMySchedule: true,
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateScheduleCard({
    required String dateStr,
    required List<QueryDocumentSnapshot> schedules,
    required bool isMySchedule,
  }) {
    final date = DateTime.parse(dateStr);
    final formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: headerDarkColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tanggal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerDarkColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFFF9A887),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMySchedule ? myScheduleColor : Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isMySchedule ? "Jadwal Saya" : "Semua Jadwal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List jadwal untuk tanggal tersebut
          Column(
            children: [
              for (int index = 0; index < schedules.length; index++)
                _buildScheduleItem(
                  doc: schedules[index],
                  index: index,
                  totalItems: schedules.length,
                  isMySchedule: isMySchedule,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required QueryDocumentSnapshot doc,
    required int index,
    required int totalItems,
    required bool isMySchedule,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    
    final room = data['room'] ?? 'Ruangan';
    final session = data['session'] ?? 'Sesi';
    final userName = data['name'] ?? 'Pengguna';
    final dateTimestamp = data['date'] as Timestamp?;
    final isMyRequest = data['userId'] == _userId;
    
    DateTime scheduleDate = DateTime.now();
    if (dateTimestamp != null) {
      scheduleDate = dateTimestamp.toDate();
    }
    
    // Parse waktu sesi
    final timeInfo = parseSessionTime(session, scheduleDate);
    final startTime = timeInfo['start'] as DateTime;
    final endTime = timeInfo['end'] as DateTime;
    final startStr = timeInfo['startStr'] as String;
    final endStr = timeInfo['endStr'] as String;
    
    final scheduleStatus = getScheduleStatus(timeInfo);
    final statusColor = getStatusColor(scheduleStatus);
    
    // Format waktu display
    final timeText = "$startStr - $endStr";
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: rowLightColor,
        border: Border(
          bottom: index < totalItems - 1
              ? const BorderSide(color: Colors.black54, width: 0.5)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userName,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontStyle: isMyRequest ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    scheduleStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.35,
                ),
                child: Text(
                  timeText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              
              // Countdown hanya untuk Jadwal Saya dan jadwal yang belum selesai
              if (isMySchedule && scheduleStatus != "Selesai")
                _CountdownWidget(
                  endTime: endTime,
                  countdownColor: countdownColor,
                  expiredColor: expiredColor,
                ),
              
              if (isMyRequest && !isMySchedule)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: myScheduleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: myScheduleColor, width: 1),
                  ),
                  child: Text(
                    "Milik Anda",
                    style: TextStyle(
                      color: myScheduleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: headerDarkColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Memuat jadwal...",
            style: TextStyle(
              color: headerDarkColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "Terjadi kesalahan",
              style: TextStyle(
                color: headerDarkColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                error.length > 100 ? "${error.substring(0, 100)}..." : error,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A887),
                foregroundColor: Colors.white,
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.grey[400],
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Silakan buat permintaan peminjaman terlebih dahulu",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
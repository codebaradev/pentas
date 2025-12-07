import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna utama diambil dari logo PENTAS (oranye & biru)
    const Color primaryOrange = Color(0xFFF39A3E);
    const Color primaryBlue = Color(0xFF0077B6);

    return Scaffold(
      backgroundColor: Colors.white, //Warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Logo ITH (Pastikan pubspec.yaml sudah dikonfigurasi)
            Image.asset('assets/logo-ith.png', width: 120),

            const SizedBox(height: 20),

            // Deskripsi Aplikasi
            const Text(
              'Sistem Peminjaman Fasilitas\nLaboratorium Komputer\nITH',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 30),

            // Tombol "Mulai"
            ElevatedButton(
              onPressed: () {
                // Navigasi ke LoginPage saat ditekan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Mulai',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

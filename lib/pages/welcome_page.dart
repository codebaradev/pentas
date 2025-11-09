import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Logo ITH
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
                // Aksi Ketia ditekan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tombol mulai ditekan!')),
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

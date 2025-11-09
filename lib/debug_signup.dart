import 'package:flutter/material.dart';
import 'package:pentas/pages/signup_page.dart';

void main() {
  runApp(const DebugSignUpApp());
}

class DebugSignUpApp extends StatelessWidget {
  const DebugSignUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Debug Sign Up Page',
      home: SignupPage(), // halaman yang mau kamu lihat di emulator
    );
  }
}

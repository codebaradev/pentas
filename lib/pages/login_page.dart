import 'package:flutter/material.dart';
import 'package:pentas/pages/signup_page.dart';
import 'package:pentas/pages/home_page.dart';
// Mengimpor halaman home

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordObscured = true;

  final Color fieldBackgroundColor = const Color(0xFFFFF0ED);
  final Color buttonColor = const Color(0xFFF9A887);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sign in
              Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 48.0),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              TextField(
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () {
                  // Navigasi ke HomePage setelah login
                  // pushReplacement agar tidak bisa kembali ke halaman login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    // --- INI PERBAIKAN ERRORNYA ---
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lupa Password
                  GestureDetector(
                    onTap: () {
                      print('Tombol Lupa Password ditekan');
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight
                            .bold, // opsional supaya terlihat klikable
                      ),
                    ),
                  ),

                  const SizedBox(width: 45), // spasi antar teks
                  // Navigasi ke Signup
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Belum punya akun? Daftar',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold, // opsional
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

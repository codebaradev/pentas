import 'package:flutter/material.dart';
import 'package:pentas/pages/signup_page.dart';
import 'package:pentas/pages/home_page.dart';
import 'package:pentas/pages/admin/admin_home_page.dart'; // Import Admin Page
import '../service/auth_service.dart'; // Pastikan path service benar

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  // Controller untuk NIM dan Password
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  final Color fieldBackgroundColor = const Color(0xFFFFF0ED);
  final Color buttonColor = const Color(0xFFF9A887);

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA LOGIN (NIM) ---
  Future<void> _login() async {
    // 1. Ambil text dari controller NIM
    String nim = _nimController.text.trim();
    String password = _passwordController.text.trim();

    // 2. Validasi Input Kosong
    if (nim.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NIM/NIP dan Password harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 3. Panggil Service: loginUserWithNim (Bukan loginUser biasa)
    String? result = await _authService.loginUserWithNim(
      nim: nim,
      password: password,
    );

    if (result == "success") {
      // 4. Jika Sukses, Cek Role (Admin / Mahasiswa)
      String role = await _authService.getUserRole();
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == 'admin') {
        // Masuk ke Halaman Admin (Kepala Lab)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        // Masuk ke Halaman Mahasiswa (Home)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // 5. Jika Gagal
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ?? "Login Gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Text(
                'Sign In',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48.0),

              // --- INPUT NIM / NIP ---
              TextField(
                controller: _nimController,
                // Gunakan 'text' agar aman jika NIP mengandung spasi/tanda baca,
                // atau 'number' jika pasti hanya angka.
                keyboardType: TextInputType.text, 
                decoration: InputDecoration(
                  labelText: 'NIM / NIP', 
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // --- INPUT PASSWORD ---
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    }),
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // --- TOMBOL LUPA PASSWORD & DAFTAR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: Logika Lupa Password
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigasi ke Signup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: Text(
                      'Belum punya akun? Daftar',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // --- TOMBOL LOGIN ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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

  // --- 1. MENGGUNAKAN EMAIL, BUKAN NIM ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  final Color fieldBackgroundColor = const Color(0xFFFFF0ED);
  final Color buttonColor = const Color(0xFFF9A887);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 2. LOGIKA LOGIN BARU ---
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Panggil fungsi loginUser (menggunakan Email)
    String? result = await _authService.loginUser(
      email: email,
      password: password,
    );

    if (result == "success") {
      // --- 3. CEK ROLE JIKA LOGIN SUKSES ---
      String role = await _authService.getUserRole();
      
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == 'admin') {
        // Navigasi ke Halaman Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
        );
      } else {
        // Navigasi ke Halaman Mahasiswa (Home)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // Jika Login Gagal
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

              // --- 4. INPUT EMAIL ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Keyboard email
                decoration: InputDecoration(
                  labelText: 'Email', // Label diubah jadi Email
                  filled: true,
                  fillColor: fieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // INPUT PASSWORD
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

              // LUPA PASSWORD & DAFTAR
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

              // TOMBOL LOGIN
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
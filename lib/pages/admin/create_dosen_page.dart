import 'package:flutter/material.dart';
import 'package:pentas/service/auth_service.dart';

class CreateDosenPage extends StatefulWidget {
  const CreateDosenPage({super.key}); 

  @override
  State<CreateDosenPage> createState() => _CreateDosenPageState();
}

class _CreateDosenPageState extends State<CreateDosenPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Warna Tema Admin (Biru)
  final Color primaryColor = const Color(0xFF526D9D); 
  final Color backgroundColor = const Color(0xFFF0F4FA); // Biru sangat muda

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIKA BUAT AKUN ---
  Future<void> _handleCreateDosen() async {
    String name = _nameController.text.trim();
    String nip = _nipController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || nip.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Semua field harus diisi!", Colors.red);
      return;
    }

    if (password != confirm) {
      _showSnackBar("Password tidak cocok!", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Panggil Service dengan role 'dosen'
    String result = await _authService.registerUser(
      username: name,
      identifier: nip, // NIP disimpan ke database
      email: email,
      password: password,
      role: 'dosen', // <-- PENTING: Set role sebagai dosen
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (result == "success") {
      if (!mounted) return;
      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Berhasil 🎉"),
          content: const Text("Akun Dosen berhasil dibuat."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke Admin Home
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      _showSnackBar(result, Colors.red);
    }
  }
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Tambah Akun Dosen"),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Buat Akun Dosen Baru",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF526D9D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            _buildTextField("Nama Lengkap", _nameController, Icons.person),
            const SizedBox(height: 16),
            // Input NIP (Angka)
            _buildTextField("NIP", _nipController, Icons.badge, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField("Email", _emailController, Icons.email, isEmail: true),
            const SizedBox(height: 16),
            
            _buildPasswordField("Password", _passwordController, _obscurePassword, () {
              setState(() => _obscurePassword = !_obscurePassword);
            }),
            const SizedBox(height: 16),
            _buildPasswordField("Konfirmasi Password", _confirmPasswordController, _obscureConfirm, () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            }),

            const SizedBox(height: 40),

            // Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateDosen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Buat Akun",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback onToggle) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
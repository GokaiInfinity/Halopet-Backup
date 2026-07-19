import 'package:flutter/material.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/screens/auth/login_screen.dart';
import 'package:halopet_vetcare/core/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  
  String role = 'pemilik';
  bool isPasswordVisible = false;
  bool isAgreedToTerms = false;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!isAgreedToTerms) {
      showMessage(context, 'Anda harus menyetujui Syarat & Ketentuan terlebih dahulu.');
      return;
    }
    
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      showMessage(context, 'Nama, email, dan password wajib diisi.');
      return;
    }
    
    setState(() => loading = true);
    
    if (await AppDatabase.instance.emailExists(emailController.text)) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage(context, 'Email sudah digunakan.');
      return;
    }
    
    await AppDatabase.instance.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: role,
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );
    
    if (!mounted) return;
    setState(() => loading = false);
    showMessage(context, 'Registrasi berhasil. Silakan login.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkNavy, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Daftar akun', style: TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Buat akun HaloPet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              const Text('Lengkapi data berikut untuk memulai.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 32),
              
              _buildInputLabel('Nama lengkap'),
              _buildTextField(
                controller: nameController,
                hintText: 'Contoh: Adel Pratama',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              
              _buildInputLabel('Nomor telepon'),
              _buildTextField(
                controller: phoneController,
                hintText: '08xxxxxxxxxx',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              _buildInputLabel('Email'),
              _buildTextField(
                controller: emailController,
                hintText: 'nama@email.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              _buildInputLabel('Kata sandi'),
              _buildTextField(
                controller: passwordController,
                hintText: 'Minimal 8 karakter',
                icon: Icons.lock_outline,
                obscureText: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInputLabel('Alamat domisili'),
              _buildTextField(
                controller: addressController,
                hintText: 'Kota / kabupaten',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              
              _buildInputLabel('Daftar Sebagai'),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                ),
                items: const [
                  DropdownMenuItem(value: 'pemilik', child: Text('Pemilik Hewan', style: TextStyle(fontSize: 14))),
                  DropdownMenuItem(value: 'dokter', child: Text('Dokter Hewan', style: TextStyle(fontSize: 14))),
                ],
                onChanged: (value) => setState(() => role = value ?? 'pemilik'),
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24, height: 24,
                    child: Checkbox(
                      value: isAgreedToTerms,
                      onChanged: (val) => setState(() => isAgreedToTerms = val ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi HaloPet.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FA0C1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    loading ? 'Memproses...' : 'Daftar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                    child: const Text('Masuk di sini', style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkNavy)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBlue)),
      ),
    );
  }
}

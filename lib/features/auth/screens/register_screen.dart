import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final address = TextEditingController();
  bool obscure = true;
  bool agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
      }
    });
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || !agreeToTerms) return;
    final auth = context.read<AuthProvider>();
    
    final success = await auth.register(
      name: name.text,
      email: email.text,
      password: password.text,
      phone: phone.text,
    );
    
    if (success && mounted) {
      Navigator.pushNamed(context, AppRoutes.otp, arguments: {'email': email.text});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar akun',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Buat akun HaloPet',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 8),
              const Text('Lengkapi data berikut untuk memulai.',
                  style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14)),
              const SizedBox(height: 32),
              _buildFieldGroup('Nama lengkap', 'Contoh: Adel Pratama',
                  Icons.person_outline, name),
              _buildFieldGroup('Alamat domisili', 'Kota / kabupaten',
                  Icons.home_outlined, address),
              _buildFieldGroup(
                  'Nomor telepon', '08xxxxxxxxxx', Icons.phone_outlined, phone,
                  keyboardType: TextInputType.phone),
              _buildFieldGroup(
                  'Email', 'nama@email.com', Icons.email_outlined, email,
                  keyboardType: TextInputType.emailAddress),
              _buildPasswordField(),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: agreeToTerms,
                      onChanged: (v) =>
                          setState(() => agreeToTerms = v ?? false),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: Color(0xFFE0E5EC)),
                      activeColor: const Color(0xFF45A5C7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi HaloPet.',
                      style: TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(auth.error!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: agreeToTerms ? (auth.loading ? null : submit) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF45A5C7),
                  disabledBackgroundColor:
                      const Color(0xFF45A5C7).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: auth.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Daftar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    const Text('Sudah punya akun?',
                        style:
                            TextStyle(color: Color(0xFF7A93AA), fontSize: 14)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.login),
                      child: const Text('Masuk di sini',
                          style: TextStyle(
                              color: Color(0xFF45A5C7),
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGroup(String label, String hint, IconData icon,
      TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFB0C4D9)),
              prefixIcon: Icon(icon, color: const Color(0xFF7A93AA)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF45A5C7))),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kata sandi',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          TextFormField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: 'Minimal 8 karakter',
              hintStyle: const TextStyle(color: Color(0xFFB0C4D9)),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFF7A93AA)),
              suffixIcon: IconButton(
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF7A93AA)),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5EC))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF45A5C7))),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (v.length < 8) return 'Minimal 8 karakter';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

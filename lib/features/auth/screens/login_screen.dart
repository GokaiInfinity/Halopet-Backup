import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'owner@halopet.com');
  final password = TextEditingController(text: '123456');
  bool obscure = true;
  bool rememberMe = false;

  Future<void> submit() async {
    final auth = context.read<AuthProvider>();
    if (await auth.login(email.text, password.text) && mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, homeForRole(auth.user!.role), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hasError = auth.error != null;

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
        title: const Text('Masuk',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang kembali',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2646)),
            ),
            const SizedBox(height: 8),
            Text(
              hasError
                  ? 'Periksa kembali data akun yang dimasukkan.'
                  : 'Masuk untuk melanjutkan perawatan hewanmu.',
              style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 14),
            ),
            const SizedBox(height: 32),
            const Text('Email atau nomor telepon',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'nama@email.com',
                hintStyle: const TextStyle(color: Color(0xFFB0C4D9)),
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF7A93AA)),
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
            ),
            const SizedBox(height: 20),
            const Text('Kata sandi',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: 'Masukkan kata sandi',
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
                    borderSide: BorderSide(
                        color:
                            hasError ? Colors.red : const Color(0xFFE0E5EC))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color:
                            hasError ? Colors.red : const Color(0xFFE0E5EC))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color:
                            hasError ? Colors.red : const Color(0xFF45A5C7))),
              ),
            ),
            if (hasError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Email atau kata sandi tidak sesuai.',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: rememberMe,
                    onChanged: (v) => setState(() => rememberMe = v ?? false),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(color: Color(0xFFE0E5EC)),
                    activeColor: const Color(0xFF45A5C7),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Ingat saya',
                    style: TextStyle(fontSize: 14, color: Color(0xFF7A93AA))),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.forgot),
                  child: const Text('Lupa kata sandi?',
                      style: TextStyle(
                          color: Color(0xFF45A5C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: auth.loading ? null : submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
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
                  : Text(hasError ? 'Coba lagi' : 'Masuk',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
            ),
            if (hasError)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gagal masuk',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text('Pastikan email dan kata sandi sudah benar.',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasError) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE0E5EC))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('atau',
                        style: TextStyle(color: Color(0xFF7A93AA))),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE0E5EC))),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFE0E5EC)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata, color: Colors.blue, size: 32),
                    SizedBox(width: 8),
                    Text('Masuk dengan Google',
                        style: TextStyle(
                            color: Color(0xFF0F2646),
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Text('Belum punya akun?',
                      style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.register),
                    child: const Text('Daftar sekarang',
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
    );
  }
}

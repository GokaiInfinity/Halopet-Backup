import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final pass1 = TextEditingController();
  final pass2 = TextEditingController();
  bool obscure1 = true;
  bool obscure2 = true;

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Kata sandi baru',
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
            const Text('Buat kata sandi baru',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            const Text(
                'Gunakan kata sandi yang kuat dan belum\npernah dipakai sebelumnya.',
                style: TextStyle(
                    color: Color(0xFF7A93AA), fontSize: 14, height: 1.5)),
            const SizedBox(height: 32),
            const Text('Kata sandi baru',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            TextField(
              controller: pass1,
              obscureText: obscure1,
              decoration: InputDecoration(
                hintText: 'Minimal 8 karakter',
                hintStyle: const TextStyle(color: Color(0xFFB0C4D9)),
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFF7A93AA)),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure1 = !obscure1),
                  icon: Icon(
                      obscure1
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
            ),
            const SizedBox(height: 20),
            const Text('Konfirmasi kata sandi',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            TextField(
              controller: pass2,
              obscureText: obscure2,
              decoration: InputDecoration(
                hintText: 'Ulangi kata sandi',
                hintStyle: const TextStyle(color: Color(0xFFB0C4D9)),
                prefixIcon:
                    const Icon(Icons.lock_outline, color: Color(0xFF7A93AA)),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure2 = !obscure2),
                  icon: Icon(
                      obscure2
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
            ),
            const SizedBox(height: 24),
            const Text('Kata sandi harus memiliki:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 12),
            _buildCheckItem('Minimal 8 karakter', true),
            const SizedBox(height: 8),
            _buildCheckItem('Huruf besar dan huruf kecil', true),
            const SizedBox(height: 8),
            _buildCheckItem('Minimal 1 angka', false),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.login),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Simpan kata sandi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FC),
                border: Border.all(color: const Color(0xFFC0E0F6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF45A5C7)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hindari memakai nama hewan, tanggal lahir, atau kata sandi yang mudah ditebak.',
                      style: TextStyle(
                          color: Color(0xFF0F2646), fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked ? Colors.green : Colors.transparent,
            border: Border.all(
                color: checked ? Colors.green : const Color(0xFFE0E5EC)),
          ),
          child: checked
              ? const Icon(Icons.check, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: checked
                    ? const Color(0xFF0F2646)
                    : const Color(0xFF7A93AA))),
      ],
    );
  }
}

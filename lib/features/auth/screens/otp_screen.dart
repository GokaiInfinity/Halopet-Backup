import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.email});
  final String email;

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
        title: const Text('Verifikasi OTP',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3EBF8)),
              child: const Icon(Icons.email_outlined,
                  color: Color(0xFF45A5C7), size: 40),
            ),
            const SizedBox(height: 32),
            const Text('Masukkan kode verifikasi',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 12),
            Text(
              'Kode 6 digit telah dikirim ke\nemail ${email.isEmpty ? 'Anda' : email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF7A93AA), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: index < 3
                            ? const Color(0xFF45A5C7)
                            : const Color(0xFFE0E5EC),
                        width: index < 3 ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: index < 3
                      ? Text(
                          index == 0 ? '4' : (index == 1 ? '8' : '2'),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2646)),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Kirim ulang kode dalam 00:42',
                style: TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.authSuccess),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Verifikasi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                const Text('Email salah?',
                    style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ubah email',
                      style: TextStyle(
                          color: Color(0xFF45A5C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
            const Spacer(),
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
                      'Jangan bagikan kode OTP kepada siapa pun, termasuk pihak yang mengaku dari HaloPet.',
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
}

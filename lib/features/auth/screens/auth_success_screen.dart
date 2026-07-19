import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFE8F5E9)),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Akun berhasil dibuat!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 12),
              const Text(
                'Selamat bergabung di HaloPet.\nSekarang kamu dapat menambahkan profil hewan\ndan mulai berkonsultasi dengan dokter.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF7A93AA), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0E5EC)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFFD3EBF8)),
                      child: const Icon(Icons.pets, color: Color(0xFF0F2646)),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Langkah berikutnya',
                            style: TextStyle(
                                color: Color(0xFF7A93AA), fontSize: 12)),
                        Text('Tambah profil hewanmu',
                            style: TextStyle(
                                color: Color(0xFF0F2646),
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Masuk ke beranda',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

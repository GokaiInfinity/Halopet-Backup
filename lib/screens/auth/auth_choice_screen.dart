import 'package:flutter/material.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/screens/auth/login_screen.dart';
import 'package:halopet_vetcare/screens/auth/register_screen.dart';
import 'package:halopet_vetcare/core/helpers.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFC4E0F9),
                    ),
                    child: const Icon(Icons.pets, color: AppColors.darkNavy, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'HaloPet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIllustrationMock(),
                    const SizedBox(height: 40),
                    const Text(
                      'Selamat datang di HaloPet',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mulai perjalanan kesehatan yang lebih baik untuk anjing dan kucing kesayanganmu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FA0C1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => push(context, const RegisterScreen()),
                  child: const Text('Daftar akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4FA0C1), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => push(context, const LoginScreen()),
                  child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4FA0C1))),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Dengan melanjutkan, kamu menyetujui Syarat & Privasi',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationMock() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8F1F8),
          ),
        ),
        Positioned(
          left: 20,
          top: 40,
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAEBE6),
            ),
          ),
        ),
        // Dog mock
        Positioned(
          left: 50,
          top: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC79A73)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkNavy)),
                  const SizedBox(width: 16),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkNavy)),
                ],
              ),
              Positioned(top: -5, left: 10, child: Container(width: 15, height: 20, decoration: const BoxDecoration(color: Color(0xFFB1815B), borderRadius: BorderRadius.vertical(top: Radius.circular(10))))),
              Positioned(top: -5, right: 10, child: Container(width: 15, height: 20, decoration: const BoxDecoration(color: Color(0xFFB1815B), borderRadius: BorderRadius.vertical(top: Radius.circular(10))))),
            ],
          ),
        ),
        // Cat mock
        Positioned(
          right: 30,
          bottom: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFF4FA0C1), width: 2)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkNavy)),
                  const SizedBox(width: 12),
                  Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.darkNavy)),
                ],
              ),
              Positioned(top: -8, left: 8, child: Transform.rotate(angle: -0.5, child: const Icon(Icons.change_history, size: 24, color: Color(0xFF4FA0C1)))),
              Positioned(top: -8, right: 8, child: Transform.rotate(angle: 0.5, child: const Icon(Icons.change_history, size: 24, color: Color(0xFF4FA0C1)))),
            ],
          ),
        ),
      ],
    );
  }
}

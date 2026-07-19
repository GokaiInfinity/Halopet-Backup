import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets, color: Color(0xFF0F2646), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'HaloPet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2646),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEFE8DA),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFD3EBF8),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 40,
                        bottom: 60,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD69F7E),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                  top: 25,
                                  left: 20,
                                  child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0F2646)))),
                              Positioned(
                                  top: 25,
                                  right: 20,
                                  child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0F2646)))),
                              Positioned(
                                  top: 40,
                                  child: Container(
                                      width: 12,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF0F2646),
                                          borderRadius:
                                              BorderRadius.circular(4)))),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: 40,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xFF2898D8), width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Positioned(
                                  top: -10,
                                  left: 10,
                                  child: Icon(Icons.change_history,
                                      color: Color(0xFF2898D8), size: 24)),
                              const Positioned(
                                  top: -10,
                                  right: 10,
                                  child: Icon(Icons.change_history,
                                      color: Color(0xFF2898D8), size: 24)),
                              Positioned(
                                  top: 20,
                                  left: 15,
                                  child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0F2646)))),
                              Positioned(
                                  top: 20,
                                  right: 15,
                                  child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0F2646)))),
                              Positioned(
                                  top: 35,
                                  child: Container(
                                      width: 10,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF0F2646),
                                          borderRadius:
                                              BorderRadius.circular(3)))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Selamat datang di HaloPet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2646),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mulai perjalanan kesehatan yang lebih baik\nuntuk anjing dan kucing kesayanganmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A93AA),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.register),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Daftar akun',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF45A5C7)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Masuk',
                    style: TextStyle(
                        color: Color(0xFF45A5C7),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(height: 32),
              const Text(
                'Dengan melanjutkan, kamu menyetujui Syarat & Privasi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Color(0xFF7A93AA)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

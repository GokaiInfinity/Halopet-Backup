import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: const Text('Lewati',
                style: TextStyle(
                    color: Color(0xFF2898D8), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _buildPage(
                    illustration: _buildIllustration1(),
                    title: 'Konsultasi dokter hewan\ndari mana saja',
                    description:
                        'Terhubung dengan dokter hewan terpercaya\nmelalui chat, suara, atau video call.',
                  ),
                  _buildPage(
                    illustration: _buildIllustration2(),
                    title: 'Catat kesehatan hewan\nlebih rapi',
                    description:
                        'Simpan profil, vaksinasi, alergi, dan\nriwayat konsultasi dalam satu aplikasi.',
                  ),
                  _buildPage(
                    illustration: _buildIllustration3(),
                    title: 'Pantau perawatan\ndan resep',
                    description:
                        'Dapatkan pengingat obat, kontrol, serta\nmonitoring perkembangan kondisi hewan.',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF2898D8)
                        : const Color(0xFFC0E0F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF45A5C7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  _currentIndex == 2 ? 'Mulai sekarang' : 'Lanjut',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentIndex + 1} dari 3',
              style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      {required Widget illustration,
      required String title,
      required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 250,
            child: illustration,
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F2646),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A93AA),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration1() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 40,
          top: 60,
          child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF2E7D3))),
        ),
        Positioned(
          right: 50,
          bottom: 20,
          child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE9D8B6))),
        ),
        Positioned(
          left: 50,
          bottom: 40,
          child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3EBF8))),
        ),
        Container(
          width: 130,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF0F2646), width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: const Alignment(0, -0.4),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF6E7D2),
                      border: Border.all(color: Colors.white, width: 3)),
                  child: Center(
                    child: Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF0F2646))),
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, 0.4),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF2898D8), width: 1.5)),
                  child:
                      const Icon(Icons.add, color: Color(0xFF2898D8), size: 32),
                ),
              ),
              Align(
                alignment: const Alignment(0.8, -0.7),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6)),
                  child:
                      const Icon(Icons.videocam, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 35,
          right: 55,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF90CFF6)),
            child: const Icon(Icons.pets, color: Color(0xFF0F2646), size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration2() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 40,
          top: 70,
          child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3EBF8))),
        ),
        Positioned(
          right: 30,
          bottom: 30,
          child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE9D8B6))),
        ),
        Container(
          width: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E5EC)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFFBEE1FA)),
                    child: const Icon(Icons.pets,
                        color: Color(0xFF0F2646), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Milo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F2646))),
                      Text('Kucing • 2 tahun',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF7A93AA))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              _buildTimelineItem(
                  color: Colors.green,
                  title: 'Vaksin lengkap',
                  date: '12 Mei 2026'),
              _buildTimelineItem(
                  color: const Color(0xFF2898D8),
                  title: 'Konsultasi kulit',
                  date: '8 Juli 2026'),
              _buildTimelineItem(
                  color: Colors.orange,
                  title: 'Pengingat obat',
                  date: '',
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
      {required Color color,
      required String title,
      required String date,
      bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: color)),
            if (!isLast)
              Container(width: 2, height: 24, color: const Color(0xFFE0E5EC)),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F2646))),
            if (date.isNotEmpty)
              Text(date,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
            if (!isLast) const SizedBox(height: 12),
          ],
        )
      ],
    );
  }

  Widget _buildIllustration3() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 40,
          top: 60,
          child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE9D8B6))),
        ),
        Positioned(
          right: 50,
          bottom: 20,
          child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE9D8B6))),
        ),
        Positioned(
          left: 50,
          bottom: 50,
          child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3EBF8))),
        ),
        Container(
          width: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0E5EC)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monitoring Hari ke-3',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: const Color(0xFF2898D8),
                              borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE0E5EC),
                              borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE0E5EC),
                              borderRadius: BorderRadius.circular(3)))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD3EBF8),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.medication,
                        color: Color(0xFF2898D8), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amoxicillin',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0F2646))),
                      Text('2x sehari',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF7A93AA))),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildCheckItem('Pagi', true),
              const SizedBox(height: 6),
              _buildCheckItem('Siang', true),
              const SizedBox(height: 6),
              _buildCheckItem('Malam', false),
            ],
          ),
        ),
      ],
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
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2646))),
      ],
    );
  }
}

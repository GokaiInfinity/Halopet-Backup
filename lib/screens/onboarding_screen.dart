import 'package:flutter/material.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/screens/auth/auth_choice_screen.dart';
import 'package:halopet_vetcare/core/helpers.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
    }
  }

  void _skip() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthChoiceScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text('Lewati', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage(
                    illustration: _buildOnlineConsultationMockup(),
                    title: 'Konsultasi Dokter Hewan Online',
                    subtitle: 'Tanya jawab langsung dengan dokter hewan terpercaya kapan saja dan di mana saja.',
                  ),
                  _buildPage(
                    illustration: _buildMedicalRecordMockup(),
                    title: 'Catat kesehatan hewan lebih rapi',
                    subtitle: 'Simpan profil, vaksinasi, alergi, dan riwayat konsultasi dalam satu aplikasi.',
                  ),
                  _buildPage(
                    illustration: _buildMonitoringMockup(),
                    title: 'Pantau perawatan dan resep',
                    subtitle: 'Dapatkan pengingat obat, kontrol, serta monitoring perkembangan kondisi hewan.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => _buildDot(index)),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FA0C1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2 ? 'Mulai sekarang' : 'Lanjut',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${_currentPage + 1} dari 3', style: const TextStyle(color: Color(0xFF8C95A1), fontSize: 13)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    bool active = _currentPage == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4FA0C1) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage({required Widget illustration, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineConsultationMockup() {
    return _buildMockupContainer(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFC4E0F9), child: Icon(Icons.person, color: AppColors.primaryBlue)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('drh. Citra Lestari', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                  Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildChatBubble('Halo, ada yang bisa dibantu?', true),
          const SizedBox(height: 8),
          _buildChatBubble('Anjing saya muntah sejak pagi dok.', false),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isDoctor) {
    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDoctor ? const Color(0xFFF3F4F6) : const Color(0xFFE8F1F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildMedicalRecordMockup() {
    return _buildMockupContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFC4E0F9)),
                child: const Icon(Icons.pets, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Milo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkNavy)),
                  Text('Kucing • 2 tahun', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTimelineItem('Vaksin lengkap', '12 Mei 2026', Colors.green),
          _buildTimelineItem('Konsultasi kulit', '8 Juli 2026', Colors.blue),
          _buildTimelineItem('Pengingat obat', 'Hari ini', Colors.orange, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, Color color, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
            if (!isLast) Container(width: 2, height: 25, color: Colors.grey.withOpacity(0.3)),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkNavy)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildMonitoringMockup() {
    return _buildMockupContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monitoring Hari ke-3', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: 0.6, backgroundColor: Colors.grey.shade200, color: const Color(0xFF4FA0C1), minHeight: 6),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFC4E0F9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medication, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Amoxicillin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('2x sehari', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCheckItem('Pagi', true),
          _buildCheckItem('Siang', true),
          _buildCheckItem('Malam', false),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(checked ? Icons.check_circle : Icons.circle_outlined, color: checked ? Colors.green : Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMockupContainer({required Widget child}) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -20,
          bottom: 20,
          child: Container(width: 60, height: 60, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3E8D6))),
        ),
        Positioned(
          right: -10,
          bottom: -10,
          child: Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3E8D6))),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: child,
        ),
      ],
    );
  }
}

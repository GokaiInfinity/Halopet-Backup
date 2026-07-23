import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../providers/auth_provider.dart';

import '../../database/database_helper.dart';

// ==== PROFIL DOKTER ====
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profil Dokter',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<Map<String, Object?>?>(
                future: DatabaseHelper.instance.getDoctorByUser(user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final doctor = snapshot.data;
                  final doctorName = user.name;
                  final doctorEmail = user.email;
                  final doctorPhone = user.phone;
                  final doctorSip = doctor?['license'] as String? ?? '-';
                  final doctorExperience = doctor?['experience'] as int? ?? 0;
                  final doctorSpecialist = doctor?['specialist'] as String? ?? 'Umum';

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            // HEADER
                            Center(
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Color(0xFFE6F0F9),
                                      child: Icon(Icons.person,
                                          color: Colors.blue, size: 40)),
                                  const SizedBox(height: 16),
                                  Text(doctorName,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F2646))),
                                  const SizedBox(height: 4),
                                  const Text('Dokter Hewan',
                                      style: TextStyle(color: Color(0xFF7A93AA))),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20)),
                                    child: const Text('Aktif',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // INFORMASI
                            const Text('Informasi',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF0F2646))),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                                Icons.badge_outlined, 'SIP Vet', doctorSip),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                                Icons.email_outlined, 'Email', doctorEmail),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                                Icons.phone_outlined, 'No. Telepon', doctorPhone),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                                Icons.work_outline, 'Pengalaman', '$doctorExperience Tahun pengalaman'),
                            const SizedBox(height: 32),

                            // SPESIALISASI
                            const Text('Spesialisasi',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF0F2646))),
                            const SizedBox(height: 16),
                            Wrap(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Text(doctorSpecialist,
                                      style: const TextStyle(
                                          color: Color(0xFF2196F3),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Edit Profil',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              color: Color(0xFFF0F4F8), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF7A93AA), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != 'No. Telepon' &&
                  label !=
                      'Pengalaman') // Adjusting based on mockup which hides some labels
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF7A93AA))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF0F2646))),
            ],
          ),
        ),
      ],
    );
  }
}

// ==== MOCKUP 19: PENGATURAN ====
class DoctorSettingsScreen extends StatelessWidget {
  const DoctorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DoctorScaffold(
      title: 'Pengaturan',
      index: 4,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Akun',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(
              Icons.person_outline, 'Profil Dokter', 'Ubah informasi profil',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.doctorProfileDetail)),
          const SizedBox(height: 24),
          const Text('Keamanan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(Icons.lock_outline, 'Ubah Kata Sandi',
              'Perbarui kata sandi akun Anda'),
          const SizedBox(height: 24),
          const Text('Notifikasi',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(Icons.notifications_none, 'Pengaturan Notifikasi',
              'Kelola preferensi notifikasi'),
          const SizedBox(height: 24),
          const Text('Lainnya',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItemTextTrailing('Bahasa', 'Indonesia >'),
          const SizedBox(height: 16),
          _buildSettingsItemOnlyText('Bantuan & Dukungan',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.doctorSupport)),
          const SizedBox(height: 16),
          _buildSettingsItemOnlyText('Tentang HaloPet'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (route) => false);
                  }
                },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF0F2646)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemTextTrailing(String title, String trailingText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          Text(trailingText, style: const TextStyle(color: Color(0xFF7A93AA))),
        ],
      ),
    );
  }

  Widget _buildSettingsItemOnlyText(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (title.contains('Bantuan'))
                  const Icon(Icons.help_outline,
                      color: Color(0xFF0F2646), size: 20),
                if (title.contains('Tentang'))
                  const Icon(Icons.info_outline,
                      color: Color(0xFF0F2646), size: 20),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              ],
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 20: BANTUAN & DUKUNGAN ====
class DoctorSupportScreen extends StatelessWidget {
  const DoctorSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bantuan & Dukungan',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.headset_mic_outlined,
                  color: Color(0xFF0F2646)),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                // Mock illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F0F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent,
                      size: 60, color: Color(0xFF2196F3)),
                ),
                const SizedBox(height: 24),
                const Text('Ada yang bisa kami bantu?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2646))),
                const SizedBox(height: 8),
                const Text(
                  'Temukan jawaban, panduan, dan dukungan\nuntuk pengalaman terbaik di HaloPet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF7A93AA), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Topik Bantuan',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 16),
          _buildHelpTopic(Icons.chat_bubble_outline, 'Cara Konsultasi',
              'Panduan konsultasi online', Colors.blue),
          _buildHelpTopic(Icons.payment, 'Pembayaran',
              'Metode pembayaran dan refund', Colors.green),
          _buildHelpTopic(Icons.receipt_long, 'Resep & Obat',
              'Informasi resep dan obat', Colors.orange),
          _buildHelpTopic(Icons.calendar_month, 'Jadwal',
              'Kelola jadwal konsultasi', Colors.purple),
          _buildHelpTopic(Icons.person_outline, 'Akun & Profil',
              'Pengaturan akun dan profil', Colors.blue),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6F0F9)),
            ),
            child: Column(
              children: [
                const Text('Masih butuh bantuan?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
                const SizedBox(height: 4),
                const Text('Hubungi tim kami melalui WhatsApp.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Hubungi Kami',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHelpTopic(
      IconData icon, String title, String subtitle, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF0F4F8)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.shade50, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F2646))),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
        onTap: () {},
      ),
    );
  }
}

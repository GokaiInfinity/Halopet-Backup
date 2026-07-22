import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';

// ==== MOCKUP 07: DASHBOARD ADMIN ====
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: '',
      index: 0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF0F2646)),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Color(0xFF0F2646)),
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.adminNotifications),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE6F0F9),
                        child: Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // GREETING
              const Text('Selamat pagi, Admin! 👋',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 4),
              const Text('Berikut ringkasan aktivitas hari ini.',
                  style: TextStyle(color: Color(0xFF7A93AA))),
              const SizedBox(height: 24),

              // RINGKASAN HARI INI
              const Text('Ringkasan Hari ini',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem('128', 'Konsultasi\nHari ini'),
                  _buildSummaryItem('45', 'Pasien\nBaru'),
                  _buildSummaryItem('12', 'Dokter\nAktif'),
                  _buildSummaryItem('8', 'Transaksi\nBelum Lunas'),
                ],
              ),
              const SizedBox(height: 32),

              // MENU CEPAT
              const Text('Menu Cepat',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildQuickMenu(Icons.chat_bubble_outline, 'Konsultasi', () {
                    Navigator.pushNamed(context, AppRoutes.adminConsultations);
                  }),
                  _buildQuickMenu(
                      Icons.pets,
                      'Pasien',
                      () => Navigator.pushNamed(
                          context, AppRoutes.adminPatients)),
                  _buildQuickMenu(
                      Icons.medical_services_outlined,
                      'Dokter',
                      () =>
                          Navigator.pushNamed(context, AppRoutes.adminDoctors)),
                  _buildQuickMenu(
                      Icons.payment,
                      'Pembayaran',
                      () => Navigator.pushNamed(
                          context, AppRoutes.adminTransactions)),
                  _buildQuickMenu(
                      Icons.insert_chart_outlined,
                      'Laporan',
                      () =>
                          Navigator.pushNamed(context, AppRoutes.adminReports)),
                  _buildQuickMenu(
                      Icons.article_outlined,
                      'Layanan',
                      () => Navigator.pushNamed(
                          context,
                          AppRoutes
                              .adminServices)), // Replaced "Konten" with "Layanan" for better flow
                  _buildQuickMenu(Icons.group_outlined, 'Pengguna',
                      () => Navigator.pushNamed(context, AppRoutes.adminUsers)),
                  _buildQuickMenu(
                      Icons.settings_outlined,
                      'Pengaturan',
                      () => Navigator.pushNamed(
                          context, AppRoutes.adminSettings)),
                ],
              ),
              const SizedBox(height: 32),

              // AKTIVITAS TERBARU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aktivitas Terbaru',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF0F2646))),
                  TextButton(
                      onPressed: () {},
                      child: const Text('Lihat semua >',
                          style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                  Icons.chat_bubble,
                  Colors.blue,
                  'Konsultasi baru dengan Drh. Anisa Putri',
                  'Pasien: Milo (Golden Retriever)',
                  '10 menit yang lalu'),
              _buildActivityItem(
                  Icons.payment,
                  Colors.green,
                  'Pembayaran diterima',
                  'INV-2025-0512-001',
                  '30 menit yang lalu'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F2646))),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
      ],
    );
  }

  Widget _buildQuickMenu(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF2196F3)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7A93AA),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      IconData icon, Color color, String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF7A93AA), fontSize: 12)),
                const SizedBox(height: 4),
                Text(time,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// ==== MOCKUP 08: NOTIFIKASI ====
class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

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
        title: const Text('Notifikasi',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF7A93AA),
                indicator: BoxDecoration(
                  color: Color(0xFF2196F3),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.symmetric(horizontal: 20),
                tabs: [
                  Tab(text: 'Semua'),
                  Tab(text: 'Konsultasi'),
                  Tab(text: 'Sistem'),
                  Tab(text: 'Lainnya'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildNotificationItem(
                      Icons.chat_bubble,
                      Colors.blue,
                      'Konsultasi Baru',
                      'Milo (Golden Retriever) dengan Drh. Anisa Putri',
                      '10 menit lalu',
                      true),
                  _buildNotificationItem(
                      Icons.payment,
                      Colors.green,
                      'Pembayaran Berhasil',
                      'INV-2025-0512-001 telah dibayar sebesar Rp250.000',
                      '30 menit lalu',
                      false),
                  _buildNotificationItem(
                      Icons.person_add,
                      Colors.purple,
                      'Pasien Baru Terdaftar',
                      'Luna (Kucing Anggora) telah mendaftar sebagai pasien baru',
                      '1 jam lalu',
                      false),
                  _buildNotificationItem(
                      Icons.insert_chart,
                      Colors.orange,
                      'Laporan Harian Siap',
                      'Laporan harian tanggal 11 Mei 2025 siap untuk diunduh',
                      '2 jam lalu',
                      false),
                  _buildNotificationItem(
                      Icons.calendar_today,
                      Colors.blue,
                      'Pengingat Jadwal',
                      'Ada 5 jadwal konsultasi hari ini',
                      '3 jam lalu',
                      false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color color, String title,
      String subtitle, String time, bool isUnread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isUnread ? color.withOpacity(0.3) : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2646)))),
                    if (isUnread)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF7A93AA), fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text(time,
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

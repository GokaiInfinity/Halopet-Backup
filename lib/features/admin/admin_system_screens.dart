import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../providers/auth_provider.dart';

// ==== MOCKUP 17: TRANSAKSI & PEMBAYARAN ====
class AdminTransactionScreen extends StatelessWidget {
  const AdminTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Transaksi & Pembayaran',
      index: 2, // Bottom Nav Index 2
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & FILTER
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        hintStyle: const TextStyle(color: Color(0xFF7A93AA)),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF7A93AA)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.blue)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF0F2646)),
                  ),
                ],
              ),
            ),

            // TABS
            DefaultTabController(
              length: 4,
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(24)),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(24)),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        dividerColor: Colors.transparent,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua'),
                          Tab(text: 'Menunggu'),
                          Tab(text: 'Selesai'),
                          Tab(text: 'Dibatalkan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildTransactionItem(
                              'INV-2025-0519-001',
                              'Milo (Golden Retriever)',
                              'Rp150.000',
                              '19 Mei 2025',
                              'Menunggu',
                              Colors.orange),
                          _buildTransactionItem(
                              'INV-2025-0519-002',
                              'Luna (Kucing Anggora)',
                              'Rp200.000',
                              '19 Mei 2025',
                              'Selesai',
                              Colors.green),
                          _buildTransactionItem(
                              'INV-2025-0518-015',
                              'Max (Kucing Persia)',
                              'Rp250.000',
                              '18 Mei 2025',
                              'Selesai',
                              Colors.green),
                          _buildTransactionItem(
                              'INV-2025-0518-014',
                              'Bella (Poodle)',
                              'Rp120.000',
                              '18 Mei 2025',
                              'Dibatalkan',
                              Colors.red),
                          _buildTransactionItem(
                              'INV-2025-0517-009',
                              'Coco (Kucing Maine Coon)',
                              'Rp180.000',
                              '17 Mei 2025',
                              'Selesai',
                              Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String inv, String pet, String amount,
      String date, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(inv,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Color(0xFF0F2646))),
              Text(status,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(pet,
              style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              Text(date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ==== MOCKUP 18: LAPORAN & STATISTIK ====
class AdminReportScreen extends StatelessWidget {
  const AdminReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Laporan & Statistik',
      index: 3, // Bottom Nav Index 3
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DATE PICKER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('13 Mei 2025 - 19 Mei 2025',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2646))),
                    Icon(Icons.calendar_month, color: Color(0xFF0F2646)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // RINGKASAN
              const Text('Ringkasan',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                      'Total Konsultasi', '128', '+12%', Colors.green),
                  _buildStatCard('Total Pasien', '96', '+8%', Colors.green),
                  _buildStatCard(
                      'Pendapatan', 'Rp 25.450.000', '+15%', Colors.green),
                  _buildStatCard('Transaksi', '84', '+10%', Colors.green),
                ],
              ),
              const SizedBox(height: 32),

              // GRAFIK PENDAPATAN
              const Text('Grafik Pendapatan',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  // Placeholder for chart
                  child: Icon(Icons.show_chart,
                      size: 80, color: Color(0xFF2196F3)),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Detail Laporan',
                      style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String percent, Color percentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 4),
          Text(percent,
              style: TextStyle(
                  color: percentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ==== MOCKUP 19: PENGATURAN SISTEM ====
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Pengaturan Sistem',
      index: 4, // Bottom Nav Index 4
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSettingItem(Icons.support_agent, 'Tiket Bantuan',
                'Kelola tiket pengaduan pengguna',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.adminTickets)),
            _buildSettingItem(Icons.person_outline, 'Profil Admin',
                'Kelola informasi akun admin'),
            _buildSettingItem(Icons.storefront_outlined, 'Pengaturan Klinik',
                'Informasi dan detail klinik'),
            _buildSettingItem(Icons.access_time, 'Jam Operasional',
                'Atur jam buka dan tutup'),
            _buildSettingItem(Icons.notifications_outlined, 'Notifikasi',
                'Pengaturan notifikasi sistem'),
            _buildSettingItem(
                Icons.restore, 'Backup & Restore', 'Kelola data cadangan'),
            _buildSettingItem(
                Icons.security, 'Keamanan', 'Pengaturan keamanan akun'),
            _buildSettingItem(
                Icons.api, 'Integrasi', 'API & integrasi pihak ketiga'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F2646)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF7A93AA), fontSize: 12)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 20: PENGGUNA & AKSES ====
class AdminUserAccessScreen extends StatelessWidget {
  const AdminUserAccessScreen({super.key});

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
        title: const Text('Pengguna & Akses',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF0F2646)),
              onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // TABS
            DefaultTabController(
              length: 4,
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 24, left: 24, right: 24),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(24)),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(24)),
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        dividerColor: Colors.transparent,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua'),
                          Tab(text: 'Admin'),
                          Tab(text: 'Staf'),
                          Tab(text: 'Resepsionis'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildUserItem(
                              'Admin Utama', 'admin@halopet.id', 'Admin', true),
                          _buildUserItem(
                              'Rina Agustina', 'tina@halopet.id', 'Staf', true),
                          _buildUserItem('Doni Pratama', 'doni@halopet.id',
                              'Resepsionis', true),
                          _buildUserItem('Siti Nurhaliza', 'siti@halopet.id',
                              'Staf', false),
                          _buildUserItem(
                              'Andi Wijaya', 'andi@halopet.id', 'Admin', true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(String name, String email, String role, bool isActive) {
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
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE6F0F9),
            child: Icon(Icons.person, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Color(0xFF0F2646))),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        color: Color(0xFF7A93AA), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(role,
                  style: const TextStyle(
                      color: Color(0xFF0F2646),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                      color: isActive ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

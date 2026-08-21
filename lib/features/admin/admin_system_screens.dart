import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../providers/auth_provider.dart';
import '../../database/database_helper.dart';

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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance.getAdminTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final tx = snapshot.data ?? [];
                          if (tx.isEmpty) return const Center(child: Text("Belum ada transaksi"));
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: tx.length,
                            itemBuilder: (context, index) {
                              final item = tx[index];
                              Color sColor = Colors.green;
                              String sts = item['status'] ?? '';
                              if (sts == 'waiting' || sts == 'menunggu' || sts == 'scheduled') sColor = Colors.orange;
                              if (sts == 'cancelled' || sts == 'dibatalkan') sColor = Colors.red;
                              
                              return _buildTransactionItem(
                                'INV-${item['id']}',
                                '${item['pet_name']}',
                                '-', // Amount from medical_records or orders if available
                                '${item['created_at']}',
                                sts,
                                sColor
                              );
                            },
                          );
                        }
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
              FutureBuilder<Map<String, dynamic>>(
                future: DatabaseHelper.instance.getAdminReportStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stats = snapshot.data ?? {
                    'total_konsultasi': 0,
                    'total_pasien': 0,
                    'pendapatan': 0,
                    'transaksi': 0,
                  };
                  
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 110, // Fixed height for cards
                    ),
                    children: [
                      _buildStatCard(
                          'Total Konsultasi', '${stats['total_konsultasi']}', '+0%', Colors.green),
                      _buildStatCard('Total Pasien', '${stats['total_pasien']}', '+0%', Colors.green),
                      _buildStatCard(
                          'Pendapatan', 'Rp ${stats['pendapatan']}', '+0%', Colors.green),
                      _buildStatCard('Transaksi', '${stats['transaksi']}', '+0%', Colors.green),
                    ],
                  );
                }
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
            _buildSettingItem(Icons.notifications_none, 'Pengaturan Notifikasi',
                'Pengaturan notifikasi sistem',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminNotificationSettings)),
            _buildSettingItem(
                Icons.restore, 'Backup & Restore', 'Kelola data cadangan'),
            _buildSettingItem(
                Icons.security, 'Keamanan', 'Pengaturan keamanan akun'),
            _buildSettingItem(
                Icons.api, 'Integrasi', 'API & integrasi pihak ketiga',
                onTap: () => Navigator.pushNamed(context, AppRoutes.adminIntegration)),
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

// ==== MOCKUP: PENGATURAN INTEGRASI ====
class AdminIntegrationScreen extends StatelessWidget {
  const AdminIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Integrasi', style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            const Text('Kelola integrasi dengan pihak ketiga untuk sistem pembayaran (Midtrans).', style: TextStyle(color: Color(0xFF7A93AA))),
            const SizedBox(height: 24),
            
            _buildKeyField('Merchant ID', 'M484636348'),
            const SizedBox(height: 16),
            _buildKeyField('Client Key', 'Mid-client-Jx_1dcTV51vSN9Ae'),
            const SizedBox(height: 16),
            _buildKeyField('Server Key', 'Mid-server-0Fe0042EwKPiqeau9Q1a7YjV', isObscured: true),
            
            const SizedBox(height: 32),
            const Text('Setting URL endpoints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2646))),
            const SizedBox(height: 16),
            _buildUrlField('Payment Notification URL', 'http://10.0.2.2:3000/api/payment/webhook'),
            const SizedBox(height: 16),
            _buildUrlField('Finish Redirect URL', 'halopet://payment-success'),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField(String label, String value, {bool isObscured = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          obscureText: isObscured,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
              onPressed: () {},
            )
          ),
        ),
      ],
    );
  }
  
  Widget _buildUrlField(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              const Icon(Icons.link, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(url, style: const TextStyle(color: Colors.black87))),
            ],
          ),
        )
      ],
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseHelper.instance.getAllUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final users = snapshot.data ?? [];
                          if (users.isEmpty) return const Center(child: Text("Belum ada data pengguna"));
                          
                          return TabBarView(
                            children: [
                              _buildUserList(users),
                              _buildUserList(users.where((u) => u['role'] == 'admin').toList()),
                              _buildUserList(users.where((u) => u['role'] == 'owner').toList()),
                              _buildUserList(users.where((u) => u['role'] == 'doctor').toList()),
                            ],
                          );
                        }
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

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isActive = user['isActive'];
        final bool active = isActive == null ? true : (isActive == 1 || isActive == true);
        return _buildUserItem(
            user['name']?.toString() ?? 'Unknown', 
            user['email']?.toString() ?? '', 
            user['role']?.toString() ?? 'owner', 
            active);
      },
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

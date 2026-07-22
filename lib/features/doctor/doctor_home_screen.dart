import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../database/database_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';

// ==== MOCKUP 08: BERANDA DOKTER ====
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  Map<String, Object?>? doctor;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final user = context.read<AuthProvider>().user!;
    doctor = await DatabaseHelper.instance.getDoctorByUser(user.id);
    if (doctor != null) {
      await context
          .read<ConsultationProvider>()
          .loadDoctor(doctor!['id'] as int);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final items = context.watch<ConsultationProvider>().items;

    // Dummy counts for UI
    final newConsultations =
        items.where((e) => e['status'] == 'waiting').length;
    final finished = items.where((e) => e['status'] == 'finished').length;
    final cancelled = items.where((e) => e['status'] == 'cancelled').length;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          final route = [
            AppRoutes.doctorHome,
            AppRoutes.doctorPatients,
            AppRoutes.doctorSchedule,
            AppRoutes.doctorSettings
          ][i];
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda'),
          NavigationDestination(
              icon: Icon(Icons.pets_outlined),
              selectedIcon: Icon(Icons.pets),
              label: 'Pasien'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Jadwal'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Akun'),
        ],
      ),
      body: doctor == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat pagi, ${user.name.split(' ').first} 👋',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F2646)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Semangat membantu hari ini!',
                            style: TextStyle(
                                color: Color(0xFF7A93AA), fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.doctorNotifications),
                        icon: const Icon(Icons.notifications_none,
                            color: Color(0xFF0F2646)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // RINGKASAN HARI INI
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Hari Ini',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF0F2646)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(newConsultations.toString(),
                                'Konsultasi\nBaru'),
                            _buildSummaryItem('3', 'Pasien\nBaru'), // Dummy
                            _buildSummaryItem(finished.toString(), 'Selesai'),
                            _buildSummaryItem(
                                cancelled.toString(), 'Dibatalkan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // JADWAL HARI INI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jadwal Hari Ini',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF0F2646))),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.doctorSchedule),
                        child: const Text('Lihat semua >',
                            style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dummy Schedule List
                  _buildScheduleItem('09:00', 'Milo', 'Golden Retriever',
                      'Konsultasi Online', 'Berlangsung', Colors.green),
                  _buildScheduleItem('10:00', 'Luna', 'Kucing Anggora',
                      'Konsultasi Online', 'Menunggu', Colors.orange),
                  _buildScheduleItem('11:00', 'Max', 'Kucing Persia', 'Kontrol',
                      'Terjadwal', Colors.blue),

                  const SizedBox(height: 32),

                  // MENU CEPAT
                  const Text('Menu Cepat',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickMenu(
                          Icons.people,
                          'Pasien',
                          () => Navigator.pushNamed(
                              context, AppRoutes.doctorPatients)),
                      _buildQuickMenu(
                          Icons.calendar_month,
                          'Jadwal',
                          () => Navigator.pushNamed(
                              context, AppRoutes.doctorSchedule)),
                      _buildQuickMenu(
                          Icons.chat_bubble_outline,
                          'Konsultasi',
                          () => Navigator.pushNamed(
                              context, AppRoutes.doctorConsultations)),
                      _buildQuickMenu(
                          Icons.medical_information, 'Catatan\nMedis', () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryItem(String count, String label) {
    return Column(
      children: [
        Text(count,
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

  Widget _buildScheduleItem(String time, String petName, String breed,
      String type, String status, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F4F8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: Colors.blue.withOpacity(0.05),
          onTap: () => Navigator.pushNamed(
              context, AppRoutes.doctorAppointmentDetail,
              arguments: '$time, 20 Mei 2025'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(time,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Color(0xFF0F2646))),
                ),
                CircleAvatar(
                  backgroundColor: const Color(0xFFF0F4F8),
                  radius: 20,
                  child: Icon(Icons.pets, color: color[300], size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(petName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF0F2646))),
                      Text(breed,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF7A93AA))),
                      const SizedBox(height: 4),
                      Text(type,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F2646))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: color.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenu(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF45A5C7), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F2646))),
        ],
      ),
    );
  }
}

// ==== MOCKUP 09: NOTIFIKASI ====
class DoctorNotificationScreen extends StatelessWidget {
  const DoctorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('Tandai semua dibaca',
                  style: TextStyle(color: Color(0xFF2196F3))),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2196F3),
            unselectedLabelColor: Color(0xFF7A93AA),
            indicatorColor: Color(0xFF2196F3),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Pasien'),
              Tab(text: 'Sistem'),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildNotifItem(
                Icons.event_note,
                'Konsultasi Baru',
                'Milo (Golden Retriever) mengajukan\nkonsultasi baru.',
                '5 menit lalu',
                unread: true),
            _buildNotifItem(
                Icons.check_circle_outline,
                'Pembayaran Berhasil',
                'Pembayaran dari Luna untuk konsultasi\nberhasil diterima.',
                '30 menit lalu',
                unread: true),
            _buildNotifItem(
                Icons.alarm,
                'Pengingat Jadwal',
                'Anda memiliki jadwal konsultasi dengan\nMax dalam 15 menit.',
                '45 menit lalu'),
            _buildNotifItem(
                Icons.receipt_long,
                'Resep Disetujui',
                'Resep untuk pasien Milo telah disetujui\noleh apotek.',
                '1 jam lalu'),
            _buildNotifItem(
                Icons.settings,
                'Sistem',
                'Pembaruan sistem akan dilakukan malam\nini pada pukul 23:00 WIB.',
                '2 jam lalu'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(
      IconData icon, String title, String message, String time,
      {bool unread = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: unread ? const Color(0xFFF9FBFF) : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE6F0F9),
            child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2646))),
                    if (unread)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF556982))),
                const SizedBox(height: 8),
                Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFA5B4C2))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

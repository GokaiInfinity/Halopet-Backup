import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';

// ==== MOCKUP 10: JADWAL SAYA ====
class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  DateTime _selectedDate =
      DateTime(2025, 5, 20); // Dummy start date to match mockup

  String _formatDate(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, dynamic>> _getRawDataForDate(DateTime date) {
    if (date.day == 20 && date.month == 5 && date.year == 2025) {
      return [
        {
          'time': '09:00',
          'pet': 'Milo',
          'breed': 'Golden Retriever',
          'type': 'Konsultasi Online',
          'status': 'Berlangsung',
          'color': Colors.green
        },
        {
          'time': '10:00',
          'pet': 'Luna',
          'breed': 'Kucing Anggora',
          'type': 'Konsultasi Online',
          'status': 'Menunggu',
          'color': Colors.orange
        },
        {
          'time': '11:00',
          'pet': 'Max',
          'breed': 'Kucing Persia',
          'type': 'Kontrol',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
        {
          'time': '12:00',
          'pet': 'Bella',
          'breed': 'Anjing Poodle',
          'type': 'Konsultasi Online',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
        {
          'time': '14:00',
          'pet': 'Coco',
          'breed': 'Kucing Maine Coon',
          'type': 'Kontrol',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
      ];
    } else if (date.day % 2 == 0) {
      return [
        {
          'time': '10:00',
          'pet': 'Max',
          'breed': 'Kucing Persia',
          'type': 'Kontrol',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
        {
          'time': '14:00',
          'pet': 'Coco',
          'breed': 'Kucing Maine Coon',
          'type': 'Kontrol',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
      ];
    } else {
      return [
        {
          'time': '09:00',
          'pet': 'Milo',
          'breed': 'Golden Retriever',
          'type': 'Konsultasi Online',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
        {
          'time': '13:00',
          'pet': 'Luna',
          'breed': 'Kucing Anggora',
          'type': 'Konsultasi Online',
          'status': 'Terjadwal',
          'color': Colors.blue
        },
      ];
    }
  }

  List<Widget> _getScheduleForDate(
      BuildContext context, DateTime date, String filter) {
    var rawData = _getRawDataForDate(date);
    if (filter != 'Semua') {
      rawData = rawData
          .where((item) => (item['type'] as String).contains(filter))
          .toList();
    }

    return rawData
        .map((data) => _buildScheduleItem(
            context,
            data['time'],
            data['pet'],
            data['breed'],
            data['type'],
            data['status'],
            data['color'],
            _formatDate(date)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
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
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 16),
              child: Text('Jadwal Saya',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
            ),

            // DATE SELECTOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFF0F2646)),
                    onPressed: () {
                      setState(() {
                        _selectedDate =
                            _selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  Row(
                    children: [
                      Text(_formatDate(_selectedDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F2646))),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_month,
                          color: Color(0xFF7A93AA), size: 20),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFF0F2646)),
                    onPressed: () {
                      setState(() {
                        _selectedDate =
                            _selectedDate.add(const Duration(days: 1));
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TABS
            DefaultTabController(
              length: 3,
              child: Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua', height: 36),
                          Tab(text: 'Konsultasi', height: 36),
                          Tab(text: 'Kontrol', height: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: _getScheduleForDate(
                                context, _selectedDate, 'Semua'),
                          ),
                          ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: _getScheduleForDate(
                                context, _selectedDate, 'Konsultasi'),
                          ),
                          ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: _getScheduleForDate(
                                context, _selectedDate, 'Kontrol'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
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
                child: const Text('+ Tambah Jadwal',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
      BuildContext context,
      String time,
      String petName,
      String breed,
      String type,
      String status,
      MaterialColor color,
      String formattedDate) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
          context, AppRoutes.doctorAppointmentDetail,
          arguments: formattedDate),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F4F8)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Text(time,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF0F2646))),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(petName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF0F2646))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                  Text(breed,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF7A93AA))),
                  const SizedBox(height: 8),
                  Text(type,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F2646))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 11: DETAIL JADWAL ====
class DoctorAppointmentDetailScreen extends StatelessWidget {
  final String dateString;
  const DoctorAppointmentDetailScreen({super.key, required this.dateString});

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
        title: const Text('Detail Jadwal',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.more_horiz, color: Color(0xFF0F2646)),
              onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ANIMAL HEADER
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFF0F4F8),
                child: Icon(Icons.pets, color: Colors.brown, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Milo',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2646))),
                    const Text('Golden Retriever',
                        style:
                            TextStyle(color: Color(0xFF7A93AA), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Konsultasi Online',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // INFORMASI JADWAL
          const Text('Informasi Jadwal',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_month_outlined, dateString),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, '09:00 - 09:30 WIB'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description_outlined, 'Konsultasi Online'),
          const SizedBox(height: 32),

          // KELUHAN UTAMA
          const Text('Keluhan Utama',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          const Text(
              'Milo sering garuk-garuk dan bulu rontok di beberapa bagian.',
              style: TextStyle(color: Color(0xFF556982), height: 1.5)),
          const SizedBox(height: 32),

          // PEMILIK HEWAN
          const Text('Pemilik Hewan',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person_outline, 'Adel Pratama'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_outlined, '08xxxxxxxxx'),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2196F3)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // CATATAN TAMBAHAN
          const Text('Catatan Tambahan',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF0F2646))),
          const SizedBox(height: 8),
          const Text('Pasien baru. Mohon berikan pemeriksaan menyeluruh.',
              style: TextStyle(color: Color(0xFF556982), height: 1.5)),
          const SizedBox(height: 48),

          // ACTIONS
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Mulai Konsultasi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2196F3)),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ubah Jadwal',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2196F3))),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A93AA), size: 20),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../database/database_helper.dart';

import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';

// ==== MOCKUP 10: JADWAL SAYA ====
class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  DateTime _selectedDate = DateTime(2026, 7, 20); // Sync to DB dummy date
  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId != null) {
      final doctor = await DatabaseHelper.instance.getDoctorByUser(userId);
      if (doctor != null) {
        final events = await DatabaseHelper.instance.getDoctorCalendarEvents(doctor['id'] as int);
        if (mounted) {
          setState(() {
            _allEvents = events;
            _isLoading = false;
          });
        }
        return;
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, dynamic>> _getRawDataForDate(DateTime date) {
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _allEvents.where((e) => e['date'] == dateString).toList();
  }

  void _showDailyDetails(BuildContext context, DateTime date, List<Map<String, dynamic>> rawData) {
    if (rawData.isEmpty) return;

    Navigator.pushNamed(context, AppRoutes.doctorDailySchedule, arguments: {
      'date': date,
      'rawData': rawData,
    });
  }

  Widget _buildMonthlyCalendarView(
      BuildContext context, DateTime monthDate, String filter) {
    
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);

    int firstWeekday = firstDayOfMonth.weekday; // 1-7 (Mon-Sun)
    if (firstWeekday == 7) firstWeekday = 0; // Sun=0

    List<DateTime> daysInGrid = [];
    for (int i = 0; i < firstWeekday; i++) {
      daysInGrid.add(firstDayOfMonth.subtract(Duration(days: firstWeekday - i)));
    }
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      daysInGrid.add(DateTime(monthDate.year, monthDate.month, i));
    }
    int remainingCells = 42 - daysInGrid.length;
    for (int i = 1; i <= remainingCells; i++) {
      daysInGrid.add(lastDayOfMonth.add(Duration(days: i)));
    }

    final weekdays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: weekdays
                .map((day) => Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            day,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A93AA)),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 120, // Fixed height for each cell
            ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final date = daysInGrid[index];
                  final isCurrentMonth = date.month == monthDate.month;
                  final isToday = date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;

                  var rawData = _getRawDataForDate(date);
                  if (filter != 'Semua') {
                    rawData = rawData
                        .where((item) => (item['type'] as String).contains(filter))
                        .toList();
                  }

                  // Group by schedule_id
                  Map<int, List<Map<String, dynamic>>> groupedData = {};
                  for (var data in rawData) {
                    int sId = data['schedule_id'] ?? data.hashCode; // fallback
                    groupedData.putIfAbsent(sId, () => []).add(data);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF0F4F8)),
                      color: isToday ? const Color(0xFFE3F2FD) : Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday 
                                    ? Colors.blue 
                                    : (isCurrentMonth ? const Color(0xFF0F2646) : const Color(0xFFB0C4D9)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            children: groupedData.values.take(3).map((scheduleList) {
                              final data = scheduleList.first;
                              final isBooked = scheduleList.any((s) => s['pet'] != 'Tersedia');
                              final bookingCount = isBooked ? scheduleList.where((s) => s['pet'] != 'Tersedia').length : 0;
                              final isCompleted = isBooked && scheduleList.where((s) => s['pet'] != 'Tersedia').every((s) {
                                final st = (s['status'] as String?)?.toLowerCase() ?? '';
                                return st == 'selesai' || st == 'finished' || st == 'completed';
                              });
                              
                              final color = isBooked ? Colors.green : Colors.blue;
                              final text = isBooked ? '${data['time']} ($bookingCount Pasien)' : '${data['time']} Tersedia';

                              return InkWell(
                                onTap: isBooked ? () {
                                  Navigator.pushNamed(context, AppRoutes.doctorDailySchedule, arguments: {
                                    'date': date,
                                    'rawData': rawData,
                                  });
                                } : () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Jadwal?'),
                                      content: Text('Apakah Anda yakin ingin menghapus jadwal pukul ${data['time']}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await DatabaseHelper.instance.deleteSchedule(data['id'] as int);
                                            if (ctx.mounted) Navigator.pop(ctx);
                                            _loadData();
                                          },
                                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border(left: BorderSide(color: color, width: 2))
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            color: color.shade800,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (isCompleted)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 2),
                                          child: Icon(Icons.check_circle, size: 10, color: Color(0xFF1B5E20)), // Dark green color
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (groupedData.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 2),
                            child: Text(
                              '+${groupedData.length - 3} lagi',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF0F2646), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (i) {
          final route = [
            AppRoutes.doctorHome,
            AppRoutes.doctorPatients,
            AppRoutes.doctorSchedule,
            AppRoutes.doctorConsultations,
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
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Konsultasi'),
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
                            DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                      });
                    },
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          Text(_formatMonthYear(_selectedDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF0F2646))),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_month,
                              color: Color(0xFF7A93AA), size: 20),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFF0F2646)),
                    onPressed: () {
                      setState(() {
                        _selectedDate =
                            DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
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
                          _buildMonthlyCalendarView(context, _selectedDate, 'Semua'),
                          _buildMonthlyCalendarView(context, _selectedDate, 'Konsultasi'),
                          _buildMonthlyCalendarView(context, _selectedDate, 'Kontrol'),
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
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.doctorAddSchedule);
                  if (result == true) {
                    _loadData();
                  }
                },
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
}

// ==== MOCKUP 11: DETAIL JADWAL ====
class DoctorAppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const DoctorAppointmentDetailScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final dateString = args['date'] as String? ?? '2026-07-31';
    final event = args['event'] as Map<String, dynamic>? ?? {};
    final petName = event['pet'] as String? ?? 'Milo';
    final breed = event['breed'] as String? ?? 'Golden Retriever';
    final time = event['time'] as String? ?? '09:00';
    final type = event['type'] as String? ?? 'Konsultasi Online';
    final status = event['status'] as String? ?? 'Selesai';
    final isBooked = petName != 'Tersedia';
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
                    Text(petName,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2646))),
                    Text(breed,
                        style:
                            const TextStyle(color: Color(0xFF7A93AA), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(type,
                    style: const TextStyle(
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
          _buildInfoRow(Icons.access_time, '$time WIB'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description_outlined, type),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Diarahkan ke daftar konsultasi aktif (jadwal ini adalah data contoh)')));
              Navigator.pushReplacementNamed(
                  context, AppRoutes.doctorConsultations);
            },
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

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../database/database_helper.dart';
import '../../utils/pdf_admin_report_generator.dart';

// ==== MOCKUP 07: DASHBOARD ADMIN ====
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'Bulan Ini';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat pagi, Admin! 👋';
    } else if (hour < 15) {
      return 'Selamat siang, Admin! ☀️';
    } else if (hour < 18) {
      return 'Selamat sore, Admin! 🌤️';
    } else {
      return 'Selamat malam, Admin! 🌙';
    }
  }

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
              Text(_getGreeting(),
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 4),
              const Text('Berikut ringkasan aktivitas hari ini.',
                  style: TextStyle(color: Color(0xFF7A93AA))),
              const SizedBox(height: 24),

              // RINGKASAN HARI INI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _startDate != null && _endDate != null
                        ? 'Ringkasan (${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month})'
                        : 'Ringkasan',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F2646))),
                  IconButton(
                    onPressed: () async {
                      final DateTime? pickedStart = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        helpText: 'Pilih Tanggal Mulai',
                      );
                      
                      if (pickedStart != null) {
                        final DateTime? pickedEnd = await showDatePicker(
                          context: context,
                          initialDate: _endDate != null && _endDate!.isAfter(pickedStart) ? _endDate! : pickedStart,
                          firstDate: pickedStart,
                          lastDate: DateTime(2030),
                          helpText: 'Pilih Tanggal Akhir',
                        );
                        
                        if (pickedEnd != null) {
                          setState(() {
                            _startDate = pickedStart;
                            _endDate = pickedEnd;
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.date_range, color: Color(0xFF2196F3)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, int>>(
                future: DatabaseHelper.instance.getAdminDashboardSummary(
                  startDate: _startDate,
                  endDate: _endDate,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stats = snapshot.data ?? {
                    'konsultasi_hari_ini': 0,
                    'jumlah_pasien': 0,
                    'jumlah_dokter': 0,
                    'transaksi_belum_lunas': 0,
                    'total_pendapatan': 0,
                  };
                  return Column(
                    children: [
                      _buildAdaptiveChartSection(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Pendapatan', style: TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
                              Text(
                                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(stats['total_pendapatan'] ?? 0),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.bar_chart, color: Colors.blue),
                                onPressed: () {
                                  _showChartDialog(context, stats, _startDate, _endDate);
                                },
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                              await PdfAdminReportGenerator.generateAndShareReport(
                                stats: stats,
                                startDate: _startDate,
                                endDate: _endDate,
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            label: const Text('Ekspor Laporan (PDF)'),
                          ),
                          ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem('${stats['konsultasi_hari_ini']}', 'Konsultasi', onTap: () {
                            Navigator.pushNamed(context, AppRoutes.adminConsultations, arguments: {
                              'startDate': _startDate ?? DateTime.now(),
                              'endDate': _endDate ?? DateTime.now(),
                            });
                          }),
                          _buildSummaryItem('${stats['jumlah_pasien']}', 'Jumlah\nPasien', onTap: () {
                            Navigator.pushNamed(context, AppRoutes.adminFilteredPatients, arguments: {
                              'startDate': _startDate ?? DateTime.now(),
                              'endDate': _endDate ?? DateTime.now(),
                            });
                          }),
                          _buildSummaryItem('${stats['jumlah_dokter']}', 'Jumlah\nDokter', onTap: () {
                            Navigator.pushNamed(context, AppRoutes.adminFilteredDoctors, arguments: {
                              'startDate': _startDate ?? DateTime.now(),
                              'endDate': _endDate ?? DateTime.now(),
                            });
                          }),
                          _buildSummaryItem('${stats['transaksi_belum_lunas']}', 'Transaksi\nBelum Lunas', onTap: () {
                            Navigator.pushNamed(context, AppRoutes.adminFilteredTransactions, arguments: {
                              'startDate': _startDate ?? DateTime.now(),
                              'endDate': _endDate ?? DateTime.now(),
                            });
                          }),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // MENU CEPAT
              const Text('Menu Cepat',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
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
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.adminNotifications),
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

  void _showChartDialog(BuildContext context, Map<String, int> stats, DateTime? startDate, DateTime? endDate) {
    final String dateString = (startDate != null && endDate != null)
        ? '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'
        : 'Hari ini (${DateFormat('dd MMM yyyy').format(DateTime.now())})';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Grafik Status Konsultasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text('Periode: $dateString', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMiniBarChart('Selesai', stats['status_finished'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.green, maxHeight: 180, width: 35),
                _buildMiniBarChart('Batal', stats['status_cancelled'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.red, maxHeight: 180, width: 35),
                _buildMiniBarChart('Jadwal', stats['status_scheduled'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.orange, maxHeight: 180, width: 35),
                _buildMiniBarChart('Tunggu', stats['status_menunggu'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.blue, maxHeight: 180, width: 35),
                _buildMiniBarChart('Blm. Lunas', stats['status_belum_lunas'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.purple, maxHeight: 180, width: 35),
                if ((stats['status_progress'] ?? 0) > 0)
                  _buildMiniBarChart('Progress', stats['status_progress'] ?? 0, stats['konsultasi_hari_ini'] ?? 1, Colors.grey, maxHeight: 180, width: 35),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildMiniBarChart(String label, int count, int total, Color color, {double maxHeight = 30.0, double width = 16.0}) {
    total = total == 0 ? 1 : total; // Mencegah division by zero
    double height = (count / total) * maxHeight;
    if (height < 4 && count > 0) height = 4; // Minimal height agar terlihat
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSummaryItem(String value, String label, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.blue.withOpacity(0.05),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
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
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenu(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
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

  Widget _buildAdaptiveChartSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getAdminChartData(
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return SizedBox(
            height: 280,
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data ?? [];
        double maxConsultations = 1;
        
        for (var row in data) {
          final c = (row['total_consultations'] as num?)?.toDouble() ?? 0;
          if (c > maxConsultations) maxConsultations = c;
        }

        final consultationBars = <BarChartGroupData>[];
        for (int i = 0; i < data.length; i++) {
          final consultations =
              (data[i]['total_consultations'] as num?)?.toDouble() ?? 0;
          consultationBars.add(BarChartGroupData(
            x: i,
            showingTooltipIndicators: [0],
            barRods: [
              BarChartRodData(
                toY: consultations == 0 ? 0.05 : consultations,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 14,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ));
        }

        Widget bottomLabel(double value, TitleMeta meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
          final parts = (data[idx]['date'] as String).split('-');
          if (parts.length != 3) return const SizedBox.shrink();
          if (data.length > 8 &&
              idx != 0 &&
              idx != data.length - 1 &&
              idx % (data.length ~/ 4) != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 6,
            child: Text('${parts[2]}/${parts[1]}',
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grafik Konsultasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2646),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 190,
                child: data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada data pada periode ini',
                              style: TextStyle(
                                  color: Color(0xFF7A93AA), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          maxY: maxConsultations * 1.3,
                          barTouchData: BarTouchData(
                            enabled: false,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.transparent,
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 4,
                              getTooltipItem:
                                  (group, gi, rod, ri) {
                                final val = rod.toY < 0.1 ? 0 : rod.toY.toInt();
                                return BarTooltipItem(
                                '$val',
                                const TextStyle(
                                    color: Color(0xFF0F2646),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              );
                            },
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval:
                                (maxConsultations / 4).ceilToDouble(),
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: const Color(0xFFE5E9F0),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: bottomLabel,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval:
                                    (maxConsultations / 4).ceilToDouble(),
                                getTitlesWidget: (v, meta) {
                                  // Show 0 label so baseline is clear
                                  if (v % 1 != 0 && v != 0) return const SizedBox.shrink(); 
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4,
                                    child: Text('${v.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF7A93AA))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: consultationBars,
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.adminReports),
                  child: const Text(
                    'Lihat Detail Laporan',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.instance.getAdminNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final notifications = snapshot.data ?? [];
                  if (notifications.isEmpty) return const Center(child: Text("Belum ada notifikasi"));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _buildNotificationItem(
                        Icons.notifications_active,
                        Colors.blue,
                        notif['title'] ?? '',
                        notif['message'] ?? '',
                        notif['created_at'] ?? '',
                        notif['is_read'] == 0
                      );
                    },
                  );
                }
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

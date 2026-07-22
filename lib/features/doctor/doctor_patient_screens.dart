import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/auth_provider.dart';

// ==== MOCKUP 12: DAFTAR PASIEN ====
class DoctorPatientListScreen extends StatelessWidget {
  const DoctorPatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
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
              child: Text('Daftar Pasien',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F2646))),
            ),

            // SEARCH & FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE0E5EC)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFF7A93AA)),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Cari nama hewan atau pemilik...',
                                hintStyle: TextStyle(
                                    color: Color(0xFF7A93AA), fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE0E5EC)),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF0F2646)),
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
                            borderRadius: BorderRadius.circular(20)),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF7A93AA),
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Semua', height: 36),
                          Tab(text: 'Hari Ini', height: 36),
                          Tab(text: 'Minggu Ini', height: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildPatientItem(
                              context,
                              '09:00',
                              'Milo',
                              'Golden Retriever',
                              'Konsultasi Online',
                              Colors.green),
                          _buildPatientItem(
                              context,
                              '10:00',
                              'Luna',
                              'Kucing Anggora',
                              'Konsultasi Online',
                              Colors.orange),
                          _buildPatientItem(context, '11:00', 'Max',
                              'Kucing Persia', 'Kontrol', Colors.blue),
                          _buildPatientItem(context, '13:00', 'Bella', 'Poodle',
                              'Konsultasi Online', Colors.green),
                          _buildPatientItem(context, '14:00', 'Coco',
                              'Maine Coon', 'Kontrol', Colors.blue),
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

  Widget _buildPatientItem(BuildContext context, String time, String petName,
      String breed, String type, MaterialColor color) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.doctorPatientDetail),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFF0F4F8),
              radius: 24,
              child: Icon(Icons.pets, color: color[300], size: 24),
            ),
            const SizedBox(width: 16),
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
                  Row(
                    children: [
                      Text(time,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF0F2646))),
                      const Text(' WIB',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF7A93AA))),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(type,
                  style: TextStyle(
                      color: color.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 13: DETAIL PASIEN ====
class DoctorPatientDetailScreen extends StatelessWidget {
  const DoctorPatientDetailScreen({super.key});

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
          title: const Text('Detail Pasien',
              style: TextStyle(
                  color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // HEADER HEWAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFF0F4F8),
                      child: Icon(Icons.pets, color: Colors.brown, size: 32)),
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
                            style: TextStyle(
                                color: Color(0xFF7A93AA), fontSize: 13)),
                        const Text('2 Tahun',
                            style: TextStyle(
                                color: Color(0xFF7A93AA), fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('Aktif',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // TABS
            const TabBar(
              labelColor: Color(0xFF2196F3),
              unselectedLabelColor: Color(0xFF7A93AA),
              indicatorColor: Color(0xFF2196F3),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Ringkasan'),
                Tab(text: 'Riwayat'),
                Tab(text: 'Catatan'),
              ],
            ),

            // TAB VIEW
            Expanded(
              child: TabBarView(
                children: [
                  _buildRingkasanTab(),
                  _buildRiwayatTab(context),
                  _buildCatatanTab(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Informasi Pemilik',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF0F2646))),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.person_outline, 'Adel Pratama'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.phone_outlined, '08xxxxxxxxx'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.email_outlined, 'adel.pratama@email.com'),
        const SizedBox(height: 32),
        const Text('Informasi Hewan',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF0F2646))),
        const SizedBox(height: 16),
        _buildInfoGridRow('Jenis Kelamin', 'Jantan'),
        const Divider(height: 24, color: Color(0xFFE0E5EC)),
        _buildInfoGridRow('Berat', '26 kg'),
        const Divider(height: 24, color: Color(0xFFE0E5EC)),
        _buildInfoGridRow('Steril', 'Ya'),
        const Divider(height: 24, color: Color(0xFFE0E5EC)),
        _buildInfoGridRow('Alergi', 'Tidak ada'),
        const SizedBox(height: 32),
        const Text('Keluhan Terakhir',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF0F2646))),
        const SizedBox(height: 12),
        const Text('Sering garuk-garuk dan bulu rontok\ndi beberapa bagian.',
            style: TextStyle(color: Color(0xFF556982), height: 1.5)),
        const SizedBox(height: 16),
        const Text('20 Mei 2025 • 09:00 WIB',
            style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
      ],
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

  Widget _buildInfoGridRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7A93AA))),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Placeholder for Riwayat, which can link to Mockup 14
  Widget _buildRiwayatTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.doctorMedicalHistory),
        child: const Text('Buka Halaman Riwayat (Mockup 14)'),
      ),
    );
  }

  // Placeholder for Catatan, which can link to Mockup 15
  Widget _buildCatatanTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.doctorMedicalNotes),
        child: const Text('Buka Halaman Catatan (Mockup 15)'),
      ),
    );
  }
}

// ==== MOCKUP 14: RIWAYAT MEDIS ====
class DoctorMedicalHistoryScreen extends StatelessWidget {
  const DoctorMedicalHistoryScreen({super.key});

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
        title: const Text('Riwayat Medis',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildTimelineItem(
            date: '20 Mei 2025 • 09:00 WIB',
            type: 'Konsultasi Online',
            keluhan: 'Garuk-garuk, bulu rontok',
            diagnosis: 'Dermatitis alergi',
            terapi: 'Cetirizine, Salep Chlorhexidine',
            isLast: false,
          ),
          _buildTimelineItem(
            date: '5 Mei 2025 • 10:00 WIB',
            type: 'Kontrol',
            keluhan: 'Membaik',
            saran: 'Lanjutkan pengobatan',
            isLast: false,
          ),
          _buildTimelineItem(
            date: '28 Apr 2025 • 09:30 WIB',
            type: 'Konsultasi Online',
            keluhan: 'Diare',
            diagnosis: 'Gastroenteritis ringan',
            terapi: 'Oralit, Metronidazole',
            isLast: false,
          ),
          _buildTimelineItem(
            date: '10 Apr 2025 • 11:00 WIB',
            type: 'Vaksinasi',
            vaksin: 'Rabies',
            dokter: context.read<AuthProvider>().user?.name ?? 'Dokter',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String type,
    String? keluhan,
    String? diagnosis,
    String? terapi,
    String? saran,
    String? vaksin,
    String? dokter,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2196F3), width: 4),
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE0E5EC),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 4),
                  Text(type,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF7A93AA))),
                  const SizedBox(height: 12),
                  if (keluhan != null)
                    Text('Keluhan: $keluhan',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                  if (saran != null)
                    Text('Kondisi: $keluhan\nSaran: $saran',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                  if (diagnosis != null)
                    Text('Diagnosis: $diagnosis',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                  if (terapi != null)
                    Text('Terapi: $terapi',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                  if (vaksin != null)
                    Text('Vaksin: $vaksin',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                  if (dokter != null)
                    Text('Dokter: $dokter',
                        style: const TextStyle(
                            color: Color(0xFF556982), fontSize: 13)),
                ],
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFE0E5EC)),
        ],
      ),
    );
  }
}

// ==== MOCKUP 15: CATATAN MEDIS ====
class DoctorMedicalNotesScreen extends StatelessWidget {
  const DoctorMedicalNotesScreen({super.key});

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
          title: const Text('Catatan Medis',
              style: TextStyle(
                  color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF7A93AA),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Semua', height: 36),
                  Tab(text: 'Pribadi', height: 36),
                  Tab(text: 'Tindakan', height: 36),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildNoteCard(
                      '20 Mei 2025 • 09:15 WIB',
                      'Catatan Pribadi',
                      'Pemilik sangat kooperatif dan mengikuti saran dengan baik.',
                      Icons.person_outline),
                  _buildNoteCard(
                      '5 Mei 2025 • 09:10 WIB',
                      'Tindakan',
                      'Diberikan edukasi perawatan bulu dan lingkungan.',
                      Icons.medical_services_outlined),
                  _buildNoteCard(
                      '5 Mei 2025 • 10:05 WIB',
                      'Catatan Pribadi',
                      'Perkembangan baik, nafsu makan sudah normal.',
                      Icons.person_outline),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.doctorAddNote),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('+ Tambah Catatan',
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

  Widget _buildNoteCard(
      String time, String type, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2646),
                  fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7A93AA), size: 16),
              const SizedBox(width: 6),
              Text(type,
                  style:
                      const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Text(content,
              style: const TextStyle(
                  color: Color(0xFF556982), height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }
}

// ==== MOCKUP 16: TAMBAH CATATAN ====
class DoctorAddNoteScreen extends StatelessWidget {
  const DoctorAddNoteScreen({super.key});

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
        title: const Text('Tambah Catatan',
            style: TextStyle(
                color: Color(0xFF0F2646), fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text('Jenis Catatan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E5EC)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Pilih jenis catatan',
                            style: TextStyle(color: Color(0xFF7A93AA))),
                        items: ['Pribadi', 'Tindakan'].map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Catatan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Tulis catatan medis di sini...',
                      hintStyle: const TextStyle(color: Color(0xFF7A93AA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('0/500',
                        style:
                            TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Tanggal & Waktu',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E5EC)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('20 Mei 2025 • 09:20 WIB',
                            style: TextStyle(
                                color: Color(0xFF0F2646),
                                fontWeight: FontWeight.w500)),
                        Icon(Icons.calendar_month_outlined,
                            color: Color(0xFF7A93AA), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simpan Catatan',
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

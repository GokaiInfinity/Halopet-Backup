import 'package:flutter/material.dart';

class PetDetailTabsScreen extends StatelessWidget {
  const PetDetailTabsScreen(
      {super.key, required this.pet, this.initialTabIndex = 0});
  final Map<String, Object?> pet;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Detail Profil Hewan',
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
          bottom: const TabBar(
            labelColor: Color(0xFF45A5C7),
            unselectedLabelColor: Color(0xFF7A93AA),
            indicatorColor: Color(0xFF45A5C7),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Fisik'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRingkasanTab(),
            _buildFisikTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: const Color(0xFFE8E2D6),
            child: Icon(
                pet['species'] == 'Anjing'
                    ? Icons.pets
                    : Icons.catching_pokemon,
                color: Colors.white,
                size: 46),
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoCard('Nama Hewan', '${pet['name']}'),
        _buildInfoCard('Jenis Hewan', '${pet['species']}'),
        _buildInfoCard('Ras', '${pet['breed']}'),
        _buildInfoCard('Jenis Kelamin', '${pet['gender']}'),
      ],
    );
  }

  Widget _buildFisikTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard('Tanggal Lahir', '${pet['tanggal_lahir'] ?? '-'}'),
        _buildInfoCard('Umur', '${pet['age']} Tahun'),
        _buildInfoCard('Berat Badan', '${pet['weight']} kg'),
        _buildInfoCard('Warna / Ciri Khusus', '${pet['warna_ciri'] ?? '-'}'),
        _buildInfoCard('Status Steril', '${pet['status_steril'] ?? '-'}'),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E5EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2646),
                  fontSize: 14)),
        ],
      ),
    );
  }
}

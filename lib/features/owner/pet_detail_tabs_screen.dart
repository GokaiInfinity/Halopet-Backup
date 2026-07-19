import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../app/routes.dart';

class PetDetailTabsScreen extends StatelessWidget {
  const PetDetailTabsScreen(
      {super.key, required this.pet, this.initialTabIndex = 0});
  final Map<String, Object?> pet;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    String petPhoto = pet['photo']?.toString() ?? '';

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Detail Profil Hewan',
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.petEdit, arguments: pet);
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF45A5C7)),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE6F4F8), width: 2),
                    ),
                    child: petPhoto.isNotEmpty
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage: FileImage(File(petPhoto)),
                          )
                        : CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFE8E2D6),
                            child: Icon(
                                pet['species'] == 'Anjing'
                                    ? Icons.pets
                                    : Icons.catching_pokemon,
                                color: Colors.white,
                                size: 48),
                          ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pet['name']}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F2646)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet['breed'].toString().isEmpty
                              ? '${pet['species']}'
                              : '${pet['breed']}',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF7A93AA)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pet['gender']} • ${pet['age']} Tahun',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFB0C4D9)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // TabBar
            const TabBar(
              labelColor: Color(0xFF0F2646),
              unselectedLabelColor: Color(0xFFB0C4D9),
              indicatorColor: Color(0xFF45A5C7),
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: 16),
              tabs: [
                Tab(text: 'Ringkasan'),
                Tab(text: 'Fisik'),
                Tab(text: 'Riwayat'),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildRingkasanTab(context),
                  _buildFisikTab(context),
                  _buildRiwayatTab(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSummaryRow('Nama Hewan', '${pet['name']}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Jenis Hewan', '${pet['species']}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Ras', '${pet['breed']}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Jenis Kelamin', '${pet['gender']}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Tanggal Lahir', '${pet['tanggal_lahir'] ?? '-'}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Umur', '${pet['age']} Tahun'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Berat Badan', '${pet['weight']} kg'),
      ],
    );
  }

  Widget _buildFisikTab(BuildContext context) {
    List<String> additionalPhotos = [];
    if (pet['additional_photos'] != null && pet['additional_photos'].toString().isNotEmpty) {
      try {
        List<dynamic> parsed = jsonDecode(pet['additional_photos'].toString());
        additionalPhotos = parsed.map((e) => e.toString()).toList();
      } catch (e) {
        // Ignore error
      }
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSummaryRow('Tanggal Lahir', '${pet['tanggal_lahir'] ?? '-'}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Umur', '${pet['age']} Tahun'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Berat Badan', '${pet['weight']} kg'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Warna / Ciri', '${pet['warna_ciri'] ?? '-'}'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Status Steril', '${pet['status_steril'] ?? '-'}'),
        
        if (additionalPhotos.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Foto Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2646))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: additionalPhotos.map((path) => GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.file(File(path), fit: BoxFit.contain),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover),
              ),
            )).toList(),
          ),
        ]
      ],
    );
  }

  Widget _buildRiwayatTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSummaryRow('Riwayat Vaksinasi', pet['riwayat_vaksin'] != null && pet['riwayat_vaksin'].toString().isNotEmpty ? '${pet['riwayat_vaksin']}' : '-'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Alergi', pet['alergi'] != null && pet['alergi'].toString().isNotEmpty ? '${pet['alergi']}' : 'Tidak ada'),
        const Divider(height: 32, color: Color(0xFFF2F4F7)),
        _buildSummaryRow('Riwayat Penyakit', pet['riwayat_penyakit'] != null && pet['riwayat_penyakit'].toString().isNotEmpty ? '${pet['riwayat_penyakit']}' : 'Tidak ada'),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF0F2646),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF7A93AA),
                fontSize: 14)),
      ],
    );
  }

  Widget _buildPlaceholderTab(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF7A93AA), fontSize: 14),
      ),
    );
  }
}

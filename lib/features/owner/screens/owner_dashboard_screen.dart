import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/role_scaffolds.dart';
import '../../../database/database_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/consultation_provider.dart';
import '../../../providers/doctor_provider.dart';
import '../../../providers/pet_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AuthProvider>().user!.id;
      context.read<PetProvider>().load(id);
      context.read<ConsultationProvider>().loadOwner(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final pets = context.watch<PetProvider>().pets;
    final consults = context.watch<ConsultationProvider>().items;

    return OwnerScaffold(
      title: '',
      index: 0,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<PetProvider>().load(user.id);
          await context.read<ConsultationProvider>().loadOwner(user.id);
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            children: [
              // HEADER
              Row(
                children: [
                  user.photo.isNotEmpty
                      ? CircleAvatar(
                          radius: 24,
                          backgroundImage: FileImage(File(user.photo)),
                        )
                      : CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFE0E5EC),
                          child: const Icon(Icons.person,
                              color: Color(0xFFB0C4D9), size: 32),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${user.name.split(' ').first}!',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F2646))),
                        const SizedBox(height: 4),
                        const Text('Semoga hari ini menyenangkan',
                            style: TextStyle(
                                color: Color(0xFF7A93AA), fontSize: 12)),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none,
                          color: Color(0xFF0F2646), size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: const Text('1',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // HEWAN KESAYANGAN
              _buildSectionHeader('Hewan Kesayangan',
                  () => Navigator.pushNamed(context, AppRoutes.ownerPets)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    ...pets.map((pet) => _buildPetCard(pet)).toList(),
                    _buildAddPetCard(context),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // MENU KONSULTASI
              _buildSectionHeader('Menu Konsultasi', () {}),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuIcon(Icons.chat, const Color(0xFFE8F5E9),
                      const Color(0xFF4CAF50), 'Konsultasi\nOnline',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.consultationWizard)),
                  _buildMenuIcon(Icons.calendar_month, const Color(0xFFE3F2FD),
                      const Color(0xFF2196F3), 'Buat Jadwal\nKonsultasi',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.doctorList)),
                  _buildMenuIcon(Icons.fact_check, const Color(0xFFFFF8E1),
                      const Color(0xFFFFC107), 'Skrining\nKondisi',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur skrining mandiri akan segera hadir')));
                      }),
                  _buildMenuIcon(Icons.local_hospital, const Color(0xFFF3E5F5),
                      const Color(0xFF9C27B0), 'Cari Klinik\nTerdekat',
                      onTap: () {}),
                ],
              ),

              const SizedBox(height: 32),

              // JADWAL KONSULTASI TERDEKAT
              _buildSectionHeader(
                  'Jadwal Konsultasi Terdekat',
                  () => Navigator.pushNamed(
                      context, AppRoutes.ownerConsultations)),
              const SizedBox(height: 16),
              _buildNearestConsultation(consults, context),

              const SizedBox(height: 32),

              // TIPS HARI INI
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2646))),
        GestureDetector(
          onTap: onTap,
          child: const Text('Lihat semua >',
              style: TextStyle(
                  color: Color(0xFF45A5C7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    IconData icon = Icons.pets;
    if (pet['species'].toString().toLowerCase().contains('kucing'))
      icon = Icons.catching_pokemon;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E5EC)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.petInfo, arguments: {
                'pet': pet,
                'tabIndex': 0,
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFFFF0D4),
                    child: Icon(icon, color: const Color(0xFFFFA000), size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(pet['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFF0F2646)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(pet['breed'].toString().isEmpty ? pet['species'] : pet['breed'],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF7A93AA)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${pet['age']} Tahun',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFB0C4D9))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPetCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF45A5C7)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final ownerId = context.read<AuthProvider>().user!.id;
              await Navigator.pushNamed(context, AppRoutes.petAdd);
              if (mounted) context.read<PetProvider>().load(ownerId);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFE6F4F8),
                    child: Icon(Icons.pets, color: Color(0xFF45A5C7), size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('Tambah\nHewan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646),
                          fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(
      IconData icon, Color bgColor, Color iconColor, String label,
      {VoidCallback? onTap}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: bgColor,
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2646))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearestConsultation(
      List<dynamic> consults, BuildContext context) {
    if (consults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E5EC)),
        ),
        child: const Text('Belum ada jadwal konsultasi terdekat.',
            style: TextStyle(color: Color(0xFF7A93AA))),
      );
    }

    final consult = consults.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E5EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE6F4F8),
            child: Icon(Icons.person, color: Color(0xFF45A5C7), size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(consult['doctor_name'] ?? 'Dokter',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F2646))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Video Call',
                          style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(consult['specialist'] ?? 'Dokter Hewan Umum',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF7A93AA))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(consult['schedule_date'] ?? 'Menunggu',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2646))),
                    const SizedBox(width: 12),
                    const Icon(Icons.circle, size: 6, color: Color(0xFF45A5C7)),
                    const SizedBox(width: 6),
                    Text(consult['schedule_time'] ?? '-',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2646))),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.chat,
                          arguments: consult),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 32),
                        side: const BorderSide(color: Color(0xFF45A5C7)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Detail',
                          style: TextStyle(
                              color: Color(0xFF45A5C7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips Hari Ini',
                    style: TextStyle(
                        color: Color(0xFF45A5C7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                SizedBox(height: 8),
                Text(
                    'Pastikan hewanmu minum cukup air setelah aktivitas dan cuaca panas.',
                    style: TextStyle(
                        color: Color(0xFF0F2646),
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFDE4B5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Color(0xFF45A5C7), size: 32),
          ),
        ],
      ),
    );
  }
}

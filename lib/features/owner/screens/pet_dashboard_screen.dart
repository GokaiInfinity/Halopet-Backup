import 'dart:convert';
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

class PetDashboardScreen extends StatefulWidget {
  const PetDashboardScreen({super.key, required this.pet});
  final Map<String, Object?> pet;

  @override
  State<PetDashboardScreen> createState() => _PetDashboardScreenState();
}

class _PetDashboardScreenState extends State<PetDashboardScreen> {
  late int selectedPetId;

  @override
  void initState() {
    super.initState();
    selectedPetId = widget.pet['id'] as int;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PetProvider>();
    final pets = p.pets;
    final selectedPet = pets.firstWhere((p) => p['id'] == selectedPetId,
        orElse: () => widget.pet);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profil Hewan',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF0F2646)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Pet List
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = pet['id'] == selectedPetId;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedPetId = pet['id'] as int);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSelected ? 3 : 0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF45A5C7), width: 2)
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFFE8E2D6),
                            child: Icon(
                                pet['species'] == 'Anjing'
                                    ? Icons.pets
                                    : Icons.catching_pokemon,
                                color: Colors.white,
                                size: 36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${pet['name']}',
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.bold,
                            color: isSelected
                                ? const Color(0xFF45A5C7)
                                : const Color(0xFF0F2646),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${pet['species']} ${pet['breed']}',
                          style: const TextStyle(
                              color: Color(0xFF7A93AA), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'Identitas Hewan',
                  subtitle: 'Data dasar dan identitas',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.petInfo,
                        arguments: {'pet': selectedPet, 'tabIndex': 0});
                  },
                ),
                _buildMenuTile(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Fisik Hewan',
                  subtitle: 'Berat, warna, dan kondisi fisik',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.petInfo,
                        arguments: {'pet': selectedPet, 'tabIndex': 1});
                  },
                ),
                _buildMenuTile(
                  icon: Icons.medical_services_outlined,
                  title: 'Riwayat Kesehatan',
                  subtitle: 'Vaksin, alergi, obat, penyakit',
                  onTap: () {},
                ),
                _buildMenuTile(
                  icon: Icons.shield_outlined,
                  title: 'Riwayat Vaksinasi',
                  subtitle: 'Jadwal dan status imunisasi',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.petVaccinations,
                        arguments: selectedPet);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.local_hospital_outlined,
                  title: 'Riwayat Penyakit',
                  subtitle: 'Penyakit dan tindakan',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.petDiseases,
                        arguments: selectedPet);
                  },
                ),
                _buildMenuTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Riwayat Konsultasi',
                  subtitle: 'Konsultasi dengan dokter',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.ownerConsultations);
                  },
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to edit profile
                Navigator.pushNamed(context, AppRoutes.petEdit,
                    arguments: selectedPet);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Edit Profil Hewan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E5EC)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F9FA),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF45A5C7), size: 20),
        ),
        title: Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
        subtitle: Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F2646))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFB0C4D9)),
      ),
    );
  }
}

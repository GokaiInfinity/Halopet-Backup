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

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});
  final Map<String, Object?> doctor;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        Center(
            child: AvatarInitials('${doctor['name']}',
                radius: 55, icon: Icons.medical_services)),
        const SizedBox(height: 18),
        Center(
            child: Text('${doctor['name']}',
                style: const TextStyle(
                    fontSize: 25, fontWeight: FontWeight.w900))),
        Center(
            child: Text('${doctor['specialist']}',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700))),
        const SizedBox(height: 22),
        Row(children: [
          Expanded(child: _stat(Icons.star, '${doctor['rating']}', 'Rating')),
          const SizedBox(width: 12),
          Expanded(
              child: _stat(Icons.badge_outlined, '${doctor['experience']} th',
                  'Pengalaman'))
        ]),
        const SizedBox(height: 20),
        const SectionTitle('Tentang dokter'),
        const SizedBox(height: 10),
        InfoCard(
            child: Text('${doctor['bio']}',
                style: const TextStyle(height: 1.6, color: AppColors.muted))),
        const SizedBox(height: 20),
        const SectionTitle('Nomor izin'),
        const SizedBox(height: 10),
        InfoCard(
            child: Text('${doctor['license']}',
                style: const TextStyle(fontWeight: FontWeight.w800))),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.booking,
                arguments: doctor),
            child: const Text('Pilih jadwal'))
      ]));
  Widget _stat(IconData i, String v, String l) => InfoCard(
          child: Column(children: [
        Icon(i, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(v,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(l, style: const TextStyle(color: AppColors.muted, fontSize: 12))
      ]));
}

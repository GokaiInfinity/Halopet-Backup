import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:halopet_vetcare/screens/admin/admin_doctors_screen.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/widgets/ui_components.dart';
import 'package:halopet_vetcare/screens/admin/admin_products_screen.dart';
import 'package:halopet_vetcare/screens/owner/products_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_dashboard.dart';
import 'package:halopet_vetcare/screens/home/home_router.dart';
import 'package:halopet_vetcare/screens/owner/doctor_list_screen.dart';
import 'package:halopet_vetcare/screens/owner/owner_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/owner_dashboard.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_profile_tab.dart';
import 'package:halopet_vetcare/screens/owner/notifications_screen.dart';
import 'package:halopet_vetcare/screens/owner/pets_screen.dart';
import 'package:halopet_vetcare/screens/owner/cart_screen.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/screens/owner/create_consultation_screen.dart';
import 'package:halopet_vetcare/screens/auth/login_screen.dart';
import 'package:halopet_vetcare/screens/auth/register_screen.dart';
import 'package:halopet_vetcare/screens/admin/reports_screen.dart';
import 'package:halopet_vetcare/screens/owner/medical_records_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_schedule_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_profile_tab.dart';
import 'package:halopet_vetcare/core/helpers.dart';
import 'package:halopet_vetcare/screens/owner/orders_screen.dart';
import 'package:halopet_vetcare/screens/admin/admin_users_screen.dart';
import 'package:halopet_vetcare/screens/doctor/doctor_dashboard.dart';
import 'package:halopet_vetcare/screens/owner/chat_screen.dart';
import 'package:halopet_vetcare/screens/owner/doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT d.*, u.name, u.email,
        COALESCE((SELECT day || ' ' || start_time || '-' || end_time FROM doctor_schedules s WHERE s.id_doctor = d.id_doctor AND s.status = 'aktif' LIMIT 1), 'Belum ada jadwal') AS schedule_text
      FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      WHERE d.verification_status = 'diterima' AND u.status = 'aktif'
      ORDER BY d.rating DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pilih Dokter',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) return const EmptyState(text: 'Belum ada dokter yang terverifikasi.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final d = doctors[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.health_and_safety, color: AppColors.darkNavy)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(d['specialization'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                            ]),
                          ),
                          Chip(label: Text('★ ${d['rating']}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Jadwal: ${d['schedule_text']}'),
                      Text('Biaya: ${money(d['consultation_fee'] as num)}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.person),
                              onPressed: () => push(context, DoctorDetailScreen(user: user, doctor: d)),
                              label: const Text('Detail'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.chat),
                              onPressed: () => push(context, CreateConsultationScreen(user: user, doctor: d)),
                              label: const Text('Konsul'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

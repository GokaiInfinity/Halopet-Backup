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

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}
class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT d.*, u.name, u.email FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      WHERE d.verification_status = 'menunggu'
      ORDER BY d.id_doctor DESC
    ''');
  }

  Future<void> _verify(int idDoctor, String status) async {
    final db = await AppDatabase.instance.database;
    await db.update('doctors', {'verification_status': status}, where: 'id_doctor = ?', whereArgs: [idDoctor]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Verifikasi Dokter',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const EmptyState(text: 'Tidak ada dokter yang sedang menunggu verifikasi.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final d = doctors[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${d['email']} • ${d['specialization']}'),
                    const SizedBox(height: 8),
                    StatusChip(status: d['verification_status'] as String),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => _verify(d['id_doctor'] as int, 'ditolak'), child: const Text('Tolak'))),
                      const SizedBox(width: 10),
                      Expanded(child: ElevatedButton(onPressed: () => _verify(d['id_doctor'] as int, 'diterima'), child: const Text('Setujui'))),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

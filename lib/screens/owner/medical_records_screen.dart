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

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    final role = user['role'];
    if (role == 'pemilik') {
      return db.rawQuery('''
        SELECT mr.*, p.pet_name, p.animal_type, u.name AS doctor_name
        FROM medical_records mr
        JOIN pets p ON p.id_pet = mr.id_pet
        JOIN consultations c ON c.id_consultation = mr.id_consultation
        JOIN doctors d ON d.id_doctor = c.id_doctor
        JOIN users u ON u.id_user = d.id_user
        WHERE p.id_user = ?
        ORDER BY mr.id_record DESC
      ''', [user['id_user']]);
    }
    if (role == 'dokter') {
      return db.rawQuery('''
        SELECT mr.*, p.pet_name, p.animal_type, owner.name AS owner_name
        FROM medical_records mr
        JOIN pets p ON p.id_pet = mr.id_pet
        JOIN consultations c ON c.id_consultation = mr.id_consultation
        JOIN doctors d ON d.id_doctor = c.id_doctor
        JOIN users owner ON owner.id_user = c.id_user
        WHERE d.id_user = ?
        ORDER BY mr.id_record DESC
      ''', [user['id_user']]);
    }
    return db.rawQuery('''
      SELECT mr.*, p.pet_name, p.animal_type, owner.name AS owner_name
      FROM medical_records mr
      JOIN pets p ON p.id_pet = mr.id_pet
      JOIN consultations c ON c.id_consultation = mr.id_consultation
      JOIN users owner ON owner.id_user = c.id_user
      ORDER BY mr.id_record DESC
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rekam Medis',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final records = snapshot.data ?? [];
          if (records.isEmpty) return const EmptyState(text: 'Belum ada rekam medis.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final r = records[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${r['pet_name']} - ${r['animal_type']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                    const SizedBox(height: 8),
                    Text('Catatan: ${r['doctor_note']}'),
                    Text('Ringkasan: ${r['condition_summary']}'),
                    Text('Rekomendasi: ${r['recommendation']}'),
                    Text('Saran obat: ${r['medicine_suggestion']}'),
                    const SizedBox(height: 6),
                    Text('Tanggal: ${r['record_date']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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

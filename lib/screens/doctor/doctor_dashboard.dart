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

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}
class _DoctorDashboardState extends State<DoctorDashboard> {
  Future<Map<String, dynamic>> _data() async {
    final db = await AppDatabase.instance.database;
    final doctorRows = await db.query('doctors', where: 'id_user = ?', whereArgs: [widget.user['id_user']], limit: 1);
    if (doctorRows.isEmpty) return {'doctor': null, 'consultations': <Map<String, dynamic>>[]};
    final doctor = doctorRows.first;
    final consultations = await db.rawQuery('''
      SELECT c.*, u.name AS owner_name, p.pet_name, p.animal_type
      FROM consultations c
      JOIN users u ON u.id_user = c.id_user
      JOIN pets p ON p.id_pet = c.id_pet
      WHERE c.id_doctor = ?
      ORDER BY c.id_consultation DESC
    ''', [doctor['id_doctor']]);
    return {'doctor': doctor, 'consultations': consultations};
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard Dokter',
      showBack: false,
      actions: [NotificationBadge(user: widget.user)],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _data(),
          builder: (context, snapshot) {
            final doctor = snapshot.data?['doctor'];
            final consultations = (snapshot.data?['consultations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                HeroHeader(name: widget.user['name'] as String, subtitle: 'Dokter Hewan', icon: Icons.health_and_safety),
                const SizedBox(height: 16),
                if (doctor != null)
                  InfoBox(
                    title: 'Profil Dokter',
                    body: 'Spesialisasi: ${doctor['specialization']}\nBiaya: ${money(doctor['consultation_fee'] as num)}\nVerifikasi: ${doctor['verification_status']}',
                  ),
                const SizedBox(height: 16),
                const SectionTitle('Daftar Konsultasi'),
                if (consultations.isEmpty) const EmptyState(text: 'Belum ada konsultasi masuk.'),
                for (final c in consultations)
                  AppCard(
                    child: ListTile(
                      leading: statusIcon(c['status'] as String),
                      title: Text('${c['pet_name']} - ${c['animal_type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Pemilik: ${c['owner_name']}\nKeluhan: ${c['complaint']}\nStatus: ${c['status']}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => push(context, ChatScreen(user: widget.user, consultationId: c['id_consultation'] as int)).then((_) => setState(() {})),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

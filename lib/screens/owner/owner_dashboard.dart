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

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}
class _OwnerDashboardState extends State<OwnerDashboard> {
  Future<Map<String, dynamic>> _loadData() async {
    final db = await AppDatabase.instance.database;
    final userId = widget.user['id_user'];
    Future<int> count(String table, String where) async {
      final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table WHERE $where', [userId]);
      return (rows.first['total'] as int?) ?? 0;
    }
    final pets = await count('pets', 'id_user = ?');
    final consultationsCount = await count('consultations', 'id_user = ?');
    final orders = await count('orders', 'id_user = ?');
    final recordsRows = await db.rawQuery('''
      SELECT COUNT(*) AS total FROM medical_records mr
      JOIN pets p ON p.id_pet = mr.id_pet
      WHERE p.id_user = ?
    ''', [userId]);

    final activeConsultations = await db.rawQuery('''
      SELECT c.*, d.specialization, u.name AS doctor_name, p.pet_name, p.animal_type
      FROM consultations c
      JOIN doctors d ON d.id_doctor = c.id_doctor
      JOIN users u ON u.id_user = d.id_user
      JOIN pets p ON p.id_pet = c.id_pet
      WHERE c.id_user = ? AND c.status != 'selesai'
      ORDER BY c.id_consultation DESC
    ''', [userId]);

    return {
      'stats': {
        'Hewan': pets,
        'Konsultasi': consultationsCount,
        'Rekam Medis': (recordsRows.first['total'] as int?) ?? 0,
        'Pesanan': orders,
      },
      'active_consultations': activeConsultations,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'HaloPet',
      showBack: false,
      actions: [NotificationBadge(user: widget.user)],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadData(),
          builder: (context, snapshot) {
            final stats = (snapshot.data?['stats'] as Map<String, int>?) ?? {'Hewan': 0, 'Konsultasi': 0, 'Rekam Medis': 0, 'Pesanan': 0};
            final activeConsultations = (snapshot.data?['active_consultations'] as List?)?.cast<Map<String, dynamic>>() ?? [];

            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                HeroHeader(name: widget.user['name'] as String, subtitle: 'Dashboard Pemilik Hewan', icon: Icons.pets),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: stats.entries.map((e) => StatCard(label: e.key, value: e.value.toString())).toList(),
                ),
                const SizedBox(height: 32),
                const SectionTitle('Konsultasi Aktif'),
                if (activeConsultations.isEmpty)
                  const EmptyState(text: 'Tidak ada konsultasi aktif. Jika Anda membutuhkan bantuan, silakan mulai konsultasi baru dari menu Konsul.')
                else
                  for (final c in activeConsultations)
                    AppCard(
                      child: ListTile(
                        leading: statusIcon(c['status'] as String),
                        title: Text('${c['doctor_name']} - ${c['specialization']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Hewan: ${c['pet_name']}\nKeluhan: ${c['complaint']}\nStatus: ${c['status']}'),
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

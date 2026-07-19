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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}
class _AdminDashboardState extends State<AdminDashboard> {
  Future<Map<String, int>> _stats() async {
    final db = await AppDatabase.instance.database;
    Future<int> count(String table, [String? where]) async {
      final query = where == null ? 'SELECT COUNT(*) AS total FROM $table' : 'SELECT COUNT(*) AS total FROM $table WHERE $where';
      final rows = await db.rawQuery(query);
      return (rows.first['total'] as int?) ?? 0;
    }
    return {
      'User': await count('users'),
      'Dokter': await count('doctors'),
      'Menunggu': await count('doctors', "verification_status = 'menunggu'"),
      'Produk': await count('products'),
      'Konsultasi': await count('consultations'),
      'Pesanan': await count('orders'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard Admin',
      showBack: false,
      actions: [NotificationBadge(user: widget.user)],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            HeroHeader(name: widget.user['name'] as String, subtitle: 'Pengelola Sistem HaloPet', icon: Icons.admin_panel_settings),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _stats(),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: data.entries.map((e) => StatCard(label: e.key, value: e.value.toString())).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Selamat datang di Panel Admin.\nGunakan menu navigasi untuk mengelola data.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

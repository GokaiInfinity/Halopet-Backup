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

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}
class _AdminUsersScreenState extends State<AdminUsersScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('users', orderBy: 'id_user DESC');
  }

  Future<void> _toggle(Map<String, dynamic> user) async {
    final db = await AppDatabase.instance.database;
    final next = user['status'] == 'aktif' ? 'nonaktif' : 'aktif';
    await db.update('users', {'status': next}, where: 'id_user = ?', whereArgs: [user['id_user']]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manajemen Pengguna',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.person, color: AppColors.darkNavy)),
                  title: Text(u['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${u['email']}\nRole: ${u['role']} • Status: ${u['status']}'),
                  isThreeLine: true,
                  trailing: TextButton(onPressed: () => _toggle(u), child: Text(u['status'] == 'aktif' ? 'Nonaktifkan' : 'Aktifkan')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

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

import 'package:halopet_vetcare/screens/auth/profile_settings_screen.dart';

class DoctorProfileTab extends StatelessWidget {
  const DoctorProfileTab({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      showBack: false,
      actions: [IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout))],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          HeroHeader(name: user['name'] as String, subtitle: 'Pengaturan Akun', icon: Icons.person),
          const SizedBox(height: 18),
          ActionTile(icon: Icons.edit, title: 'Ubah Profil', subtitle: 'Edit data pribadi dan kata sandi', onTap: () => push(context, ProfileSettingsScreen(user: user))),
          ActionTile(icon: Icons.verified, title: 'Verifikasi', subtitle: 'Lihat verifikasi oleh Admin', onTap: () {}),
          ActionTile(icon: Icons.description, title: 'Rekam Medis', subtitle: 'Lihat catatan yang pernah dibuat', onTap: () => push(context, MedicalRecordsScreen(user: user))),
          ActionTile(icon: Icons.notifications, title: 'Notifikasi', subtitle: 'Lihat pemberitahuan masuk', onTap: () => push(context, NotificationsScreen(user: user))),
        ],
      ),
    );
  }
}

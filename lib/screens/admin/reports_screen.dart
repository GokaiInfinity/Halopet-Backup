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

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  Future<Map<String, dynamic>> _load() async {
    final db = await AppDatabase.instance.database;
    final summary = await db.rawQuery('''
      SELECT
      (SELECT COUNT(*) FROM consultations) AS consultations,
      (SELECT COUNT(*) FROM medical_records) AS records,
      (SELECT COUNT(*) FROM orders) AS orders_count,
      (SELECT COALESCE(SUM(total_payment), 0) FROM payments WHERE payment_status = 'berhasil') AS revenue
    ''');
    final topProducts = await db.rawQuery('''
      SELECT p.product_name, COALESCE(SUM(od.quantity), 0) AS sold
      FROM products p
      LEFT JOIN order_details od ON od.id_product = p.id_product
      GROUP BY p.id_product
      ORDER BY sold DESC
      LIMIT 5
    ''');
    final topDoctors = await db.rawQuery('''
      SELECT u.name, COUNT(c.id_consultation) AS total
      FROM doctors d
      JOIN users u ON u.id_user = d.id_user
      LEFT JOIN consultations c ON c.id_doctor = d.id_doctor
      GROUP BY d.id_doctor
      ORDER BY total DESC
      LIMIT 5
    ''');
    return {'summary': summary.first, 'topProducts': topProducts, 'topDoctors': topDoctors};
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Laporan',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final summary = snapshot.data!['summary'] as Map<String, dynamic>;
          final topProducts = (snapshot.data!['topProducts'] as List).cast<Map<String, dynamic>>();
          final topDoctors = (snapshot.data!['topDoctors'] as List).cast<Map<String, dynamic>>();
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Wrap(spacing: 10, runSpacing: 10, children: [
                StatCard(label: 'Konsultasi', value: '${summary['consultations']}'),
                StatCard(label: 'Rekam Medis', value: '${summary['records']}'),
                StatCard(label: 'Pesanan', value: '${summary['orders_count']}'),
                StatCard(label: 'Pendapatan', value: money(summary['revenue'] as num)),
              ]),
              const SizedBox(height: 18),
              const SectionTitle('Produk Terlaris'),
              for (final p in topProducts) AppCard(child: ListTile(title: Text(p['product_name'] as String), trailing: Text('${p['sold']} terjual'))),
              const SizedBox(height: 18),
              const SectionTitle('Dokter Dengan Konsultasi Terbanyak'),
              for (final d in topDoctors) AppCard(child: ListTile(title: Text(d['name'] as String), trailing: Text('${d['total']} konsultasi'))),
            ],
          );
        },
      ),
    );
  }
}

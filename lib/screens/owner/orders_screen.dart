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

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}
class _OrdersScreenState extends State<OrdersScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    if (widget.user['role'] == 'admin') {
      return db.rawQuery('''
        SELECT o.*, u.name AS owner_name FROM orders o
        JOIN users u ON u.id_user = o.id_user
        ORDER BY o.id_order DESC
      ''');
    }
    return db.query('orders', where: 'id_user = ?', whereArgs: [widget.user['id_user']], orderBy: 'id_order DESC');
  }

  Future<void> _setStatus(int orderId, String status) async {
    final db = await AppDatabase.instance.database;
    await db.update('orders', {'order_status': status}, where: 'id_order = ?', whereArgs: [orderId]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.user['role'] == 'admin' ? 'Manajemen Pesanan' : 'Riwayat Pesanan',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return const EmptyState(text: 'Belum ada pesanan.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final o = orders[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Pesanan #${o['id_order']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      StatusChip(status: o['order_status'] as String),
                    ]),
                    const SizedBox(height: 8),
                    if (widget.user['role'] == 'admin') Text('Pemilik: ${o['owner_name']}'),
                    Text('Total: ${money(o['total_price'] as num)}'),
                    Text('Alamat: ${o['shipping_address']}'),
                    const SizedBox(height: 8),
                    if (widget.user['role'] == 'admin')
                      DropdownButtonFormField<String>(
                        value: o['order_status'] as String,
                        decoration: const InputDecoration(labelText: 'Ubah Status'),
                        items: const ['diproses', 'dikirim', 'selesai', 'batal'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => _setStatus(o['id_order'] as int, v ?? 'diproses'),
                      ),
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

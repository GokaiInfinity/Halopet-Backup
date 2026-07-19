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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}
class _ProductsScreenState extends State<ProductsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('products', where: 'status = ?', whereArgs: ['aktif'], orderBy: 'id_product DESC');
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    if (product['stock'] == 0) {
      showMessage(context, 'Stok habis.');
      return;
    }
    final db = await AppDatabase.instance.database;
    final existing = await db.query('carts', where: 'id_user = ? AND id_product = ?', whereArgs: [widget.user['id_user'], product['id_product']], limit: 1);
    if (existing.isEmpty) {
      await db.insert('carts', {'id_user': widget.user['id_user'], 'id_product': product['id_product'], 'quantity': 1, 'created_at': nowIso()});
    } else {
      final q = (existing.first['quantity'] as int) + 1;
      await db.update('carts', {'quantity': q}, where: 'id_cart = ?', whereArgs: [existing.first['id_cart']]);
    }
    if (!mounted) return;
    showMessage(context, 'Produk masuk keranjang.');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Toko Produk',
      actions: [IconButton(onPressed: () => push(context, CartScreen(user: widget.user)), icon: const Icon(Icons.shopping_cart))],
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const EmptyState(text: 'Belum ada produk aktif.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.medication, color: AppColors.darkNavy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${p['category']} • Stok ${p['stock']}', style: const TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(p['description'] as String),
                          const SizedBox(height: 8),
                          Text(money(p['price'] as num), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                        ]),
                      ),
                      IconButton(onPressed: () => _addToCart(p), icon: const Icon(Icons.add_shopping_cart, color: AppColors.primaryBlue)),
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

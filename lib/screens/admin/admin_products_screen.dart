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

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}
class _AdminProductsScreenState extends State<AdminProductsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('products', orderBy: 'id_product DESC');
  }

  Future<void> _showForm([Map<String, dynamic>? product]) async {
    final name = TextEditingController(text: product?['product_name']?.toString() ?? '');
    final category = TextEditingController(text: product?['category']?.toString() ?? '');
    final desc = TextEditingController(text: product?['description']?.toString() ?? '');
    final price = TextEditingController(text: product?['price']?.toString() ?? '');
    final stock = TextEditingController(text: product?['stock']?.toString() ?? '');
    String status = product?['status']?.toString() ?? 'aktif';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Ubah Produk'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama Produk')),
          const SizedBox(height: 8),
          TextField(controller: category, decoration: const InputDecoration(labelText: 'Kategori')),
          const SizedBox(height: 8),
          TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 2),
          const SizedBox(height: 8),
          TextField(controller: price, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: stock, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['aktif', 'nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setLocal(() => status = v ?? 'aktif'),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              final data = {
                'product_name': name.text.trim(),
                'category': category.text.trim(),
                'description': desc.text.trim(),
                'price': double.tryParse(price.text) ?? 0,
                'stock': int.tryParse(stock.text) ?? 0,
                'product_image': '',
                'status': status,
              };
              if (product == null) {
                await db.insert('products', data);
              } else {
                await db.update('products', data, where: 'id_product = ?', whereArgs: [product['id_product']]);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      )),
    );
    name.dispose();
    category.dispose();
    desc.dispose();
    price.dispose();
    stock.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Manajemen Produk',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final products = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.inventory_2, color: AppColors.darkNavy)),
                  title: Text(p['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p['category']} • ${money(p['price'] as num)}\nStok: ${p['stock']} • ${p['status']}'),
                  isThreeLine: true,
                  trailing: IconButton(onPressed: () => _showForm(p), icon: const Icon(Icons.edit)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

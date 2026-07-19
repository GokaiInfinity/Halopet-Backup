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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.rawQuery('''
      SELECT c.*, p.product_name, p.price, p.stock, p.category
      FROM carts c
      JOIN products p ON p.id_product = c.id_product
      WHERE c.id_user = ?
      ORDER BY c.id_cart DESC
    ''', [widget.user['id_user']]);
  }

  Future<void> _checkout(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;
    final address = TextEditingController(text: widget.user['address']?.toString() ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat Pengiriman'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bayar Simulasi')),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = await AppDatabase.instance.database;
    final total = items.fold<double>(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
    await db.transaction((txn) async {
      final orderId = await txn.insert('orders', {
        'id_user': widget.user['id_user'],
        'order_date': nowIso(),
        'total_price': total,
        'shipping_address': address.text.trim(),
        'order_status': 'diproses',
      });
      for (final item in items) {
        final qty = item['quantity'] as int;
        final price = (item['price'] as num).toDouble();
        await txn.insert('order_details', {
          'id_order': orderId,
          'id_product': item['id_product'],
          'quantity': qty,
          'price': price,
          'subtotal': price * qty,
        });
        await txn.rawUpdate('UPDATE products SET stock = stock - ? WHERE id_product = ?', [qty, item['id_product']]);
      }
      await txn.insert('payments', {
        'id_user': widget.user['id_user'],
        'payment_type': 'produk',
        'reference_id': orderId,
        'payment_method': 'Simulasi Transfer',
        'total_payment': total,
        'payment_status': 'berhasil',
        'payment_date': nowIso(),
      });
      await txn.delete('carts', where: 'id_user = ?', whereArgs: [widget.user['id_user']]);
      await txn.insert('notifications', {
        'id_user': widget.user['id_user'],
        'title': 'Pesanan diproses',
        'message': 'Pembayaran simulasi berhasil. Pesanan sedang diproses admin.',
        'is_read': 0,
        'created_at': nowIso(),
      });
    });
    if (!mounted) return;
    showMessage(context, 'Checkout berhasil.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrdersScreen(user: widget.user)));
  }

  Future<void> _updateQty(int cartId, int qty) async {
    final db = await AppDatabase.instance.database;
    if (qty <= 0) {
      await db.delete('carts', where: 'id_cart = ?', whereArgs: [cartId]);
    } else {
      await db.update('carts', {'quantity': qty}, where: 'id_cart = ?', whereArgs: [cartId]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Keranjang',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          final total = items.fold<double>(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
          if (items.isEmpty) return const EmptyState(text: 'Keranjang masih kosong.');
          return Column(children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final qty = item['quantity'] as int;
                  return AppCard(
                    child: ListTile(
                      title: Text(item['product_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${money(item['price'] as num)} x $qty'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () => _updateQty(item['id_cart'] as int, qty - 1), icon: const Icon(Icons.remove_circle_outline)),
                        Text('$qty'),
                        IconButton(onPressed: () => _updateQty(item['id_cart'] as int, qty + 1), icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  Expanded(child: Text('Total\n${money(total)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy))),
                  ElevatedButton(onPressed: () => _checkout(items), child: const Text('Checkout')),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

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

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}
class _PetsScreenState extends State<PetsScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    final db = await AppDatabase.instance.database;
    return db.query('pets', where: 'id_user = ?', whereArgs: [widget.user['id_user']], orderBy: 'id_pet DESC');
  }

  Future<void> _delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('pets', where: 'id_pet = ?', whereArgs: [id]);
    setState(() {});
  }

  Future<void> _showForm([Map<String, dynamic>? pet]) async {
    final name = TextEditingController(text: pet?['pet_name']?.toString() ?? '');
    final type = TextEditingController(text: pet?['animal_type']?.toString() ?? '');
    final breed = TextEditingController(text: pet?['breed']?.toString() ?? '');
    String? selectedGender = pet?['gender']?.toString();
    if (selectedGender != 'Jantan' && selectedGender != 'Betina') selectedGender = null;
    final age = TextEditingController(text: pet?['age']?.toString() ?? '');
    final weight = TextEditingController(text: pet?['weight']?.toString() ?? '');
    final history = TextEditingController(text: pet?['medical_history']?.toString() ?? '');
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(pet == null ? 'Tambah Hewan' : 'Ubah Hewan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama Hewan')),
                const SizedBox(height: 8),
                TextField(controller: type, decoration: const InputDecoration(labelText: 'Jenis Hewan')),
                const SizedBox(height: 8),
                TextField(controller: breed, decoration: const InputDecoration(labelText: 'Ras')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: const [
                    DropdownMenuItem(value: 'Jantan', child: Text('Jantan')),
                    DropdownMenuItem(value: 'Betina', child: Text('Betina')),
                  ],
                  onChanged: (value) => setStateDialog(() => selectedGender = value),
                ),
                const SizedBox(height: 8),
                TextField(controller: age, decoration: const InputDecoration(labelText: 'Umur (Contoh: 2 tahun)')),
                const SizedBox(height: 8),
                TextField(controller: weight, decoration: const InputDecoration(labelText: 'Berat Badan (Kg)'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: history, decoration: const InputDecoration(labelText: 'Riwayat Penyakit'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || type.text.trim().isEmpty) {
                  showMessage(context, 'Nama dan Jenis Hewan wajib diisi!');
                  return;
                }
                final db = await AppDatabase.instance.database;
                final data = {
                  'id_user': widget.user['id_user'],
                  'pet_name': name.text.trim(),
                  'animal_type': type.text.trim(),
                  'breed': breed.text.trim(),
                  'gender': selectedGender ?? '',
                  'age': age.text.trim(),
                  'weight': double.tryParse(weight.text) ?? 0,
                  'medical_history': history.text.trim(),
                };
                if (pet == null) {
                  await db.insert('pets', data);
                } else {
                  await db.update('pets', data, where: 'id_pet = ?', whereArgs: [pet['id_pet']]);
                }
                if (mounted) Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    type.dispose();
    breed.dispose();
    age.dispose();
    weight.dispose();
    history.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Data Hewan',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final pets = snapshot.data ?? [];
          if (pets.isEmpty) return const EmptyState(text: 'Belum ada data hewan. Tekan tombol + untuk menambah.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final p = pets[index];
              return AppCard(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.lightBlue, child: Icon(Icons.pets, color: AppColors.darkNavy)),
                  title: Text(p['pet_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${p['animal_type']} • ${p['breed']} (${p['gender']})\nUmur: ${p['age']} • Berat: ${p['weight']} kg'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _showForm(p);
                      if (value == 'delete') _delete(p['id_pet'] as int);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
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

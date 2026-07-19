import 'package:flutter/material.dart';
import 'package:halopet_vetcare/core/app_theme.dart';
import 'package:halopet_vetcare/widgets/ui_components.dart';
import 'package:halopet_vetcare/core/database.dart';
import 'package:halopet_vetcare/core/helpers.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['name'] as String? ?? '');
    phoneController = TextEditingController(text: widget.user['phone'] as String? ?? '');
    addressController = TextEditingController(text: widget.user['address'] as String? ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      showMessage(context, 'Nama tidak boleh kosong');
      return;
    }

    final db = await AppDatabase.instance.database;
    final Map<String, dynamic> updates = {
      'name': name,
      'phone': phone,
      'address': address,
    };
    
    if (password.isNotEmpty) {
      updates['password'] = password; // In a real app, hash this!
    }

    await db.update('users', updates, where: 'id_user = ?', whereArgs: [widget.user['id_user']]);

    if (!mounted) return;
    showMessage(context, 'Profil berhasil diperbarui. Silakan login ulang untuk melihat perubahan penuh.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pengaturan Akun',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const InfoBox(title: 'Edit Profil', body: 'Perbarui data diri Anda di bawah ini.'),
          const SizedBox(height: 18),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
          const SizedBox(height: 12),
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Alamat'), maxLines: 2),
          const SizedBox(height: 12),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Kata Sandi Baru (kosongkan jika tidak ingin mengubah)'), obscureText: true),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}

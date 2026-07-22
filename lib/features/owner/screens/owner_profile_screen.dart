import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/role_scaffolds.dart';
import '../../../database/database_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/consultation_provider.dart';
import '../../../providers/doctor_provider.dart';
import '../../../providers/pet_provider.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return OwnerScaffold(
      title: 'Pengaturan',
      index: 4,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Akun',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(
              Icons.person_outline, 'Profil Pemilik', 'Ubah informasi profil',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.editProfile)),
          const SizedBox(height: 24),
          const Text('Keamanan',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(Icons.lock_outline, 'Ubah Kata Sandi',
              'Perbarui kata sandi akun Anda'),
          const SizedBox(height: 24),
          const Text('Notifikasi',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItem(Icons.notifications_none, 'Pengaturan Notifikasi',
              'Kelola preferensi notifikasi'),
          const SizedBox(height: 24),
          const Text('Lainnya',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF7A93AA))),
          const SizedBox(height: 8),
          _buildSettingsItemTextTrailing('Bahasa', 'Indonesia >'),
          const SizedBox(height: 16),
          _buildSettingsItemOnlyText('Bantuan & Dukungan',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.helpCenter)),
          const SizedBox(height: 16),
          _buildSettingsItemOnlyText('Tentang HaloPet'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF0F2646)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsItemTextTrailing(String title, String trailingText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          Text(trailingText, style: const TextStyle(color: Color(0xFF7A93AA))),
        ],
      ),
    );
  }

  Widget _buildSettingsItemOnlyText(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (title.contains('Bantuan'))
                  const Icon(Icons.help_outline,
                      color: Color(0xFF0F2646), size: 20),
                if (title.contains('Tentang'))
                  const Icon(Icons.info_outline,
                      color: Color(0xFF0F2646), size: 20),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              ],
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7A93AA)),
          ],
        ),
      ),
    );
  }
}

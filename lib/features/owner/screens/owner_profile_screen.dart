import 'dart:convert';
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
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return OwnerScaffold(
        title: 'Profil',
        index: 4,
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Center(child: AvatarInitials(user.name, radius: 50)),
          const SizedBox(height: 14),
          Center(
              child: Text(user.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900))),
          Center(
              child: Text(user.email,
                  style: const TextStyle(color: AppColors.muted))),
          const SizedBox(height: 24),
          InfoCard(
              child: Column(children: [
            ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Nomor HP'),
                subtitle: Text(user.phone)),
            const Divider(),
            const ListTile(
                leading: Icon(Icons.security_outlined),
                title: Text('Privasi dan keamanan'),
                trailing: Icon(Icons.chevron_right)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Bantuan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
            )
          ])),
          const SizedBox(height: 18),
          OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted)
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (_) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'))
        ]));
  }
}

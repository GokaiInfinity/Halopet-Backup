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

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key, required this.user, required this.doctor});
  final Map<String, dynamic> user;
  final Map<String, dynamic>? doctor;

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}
class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  Future<List<Map<String, dynamic>>> _load() async {
    if (widget.doctor == null) return [];
    final db = await AppDatabase.instance.database;
    return db.query('doctor_schedules', where: 'id_doctor = ?', whereArgs: [widget.doctor!['id_doctor']], orderBy: 'id_schedule DESC');
  }

  Future<void> _showForm([Map<String, dynamic>? schedule]) async {
    final day = TextEditingController(text: schedule?['day']?.toString() ?? 'Senin - Jumat');
    final start = TextEditingController(text: schedule?['start_time']?.toString() ?? '09:00');
    final end = TextEditingController(text: schedule?['end_time']?.toString() ?? '16:00');
    String status = schedule?['status']?.toString() ?? 'aktif';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: Text(schedule == null ? 'Tambah Jadwal' : 'Ubah Jadwal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: day, decoration: const InputDecoration(labelText: 'Hari')),
          const SizedBox(height: 8),
          TextField(controller: start, decoration: const InputDecoration(labelText: 'Jam Mulai')),
          const SizedBox(height: 8),
          TextField(controller: end, decoration: const InputDecoration(labelText: 'Jam Selesai')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const ['aktif', 'nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setLocal(() => status = v ?? 'aktif'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              final data = {'id_doctor': widget.doctor!['id_doctor'], 'day': day.text, 'start_time': start.text, 'end_time': end.text, 'status': status};
              if (schedule == null) {
                await db.insert('doctor_schedules', data);
              } else {
                await db.update('doctor_schedules', data, where: 'id_schedule = ?', whereArgs: [schedule['id_schedule']]);
              }
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      )),
    );
    day.dispose();
    start.dispose();
    end.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Jadwal Dokter',
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snapshot) {
          final schedules = snapshot.data ?? [];
          if (schedules.isEmpty) return const EmptyState(text: 'Belum ada jadwal.');
          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final s = schedules[index];
              return AppCard(
                child: ListTile(
                  title: Text(s['day'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s['start_time']} - ${s['end_time']} • ${s['status']}'),
                  trailing: IconButton(onPressed: () => _showForm(s), icon: const Icon(Icons.edit)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

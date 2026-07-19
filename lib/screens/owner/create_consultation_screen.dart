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

class CreateConsultationScreen extends StatefulWidget {
  const CreateConsultationScreen({super.key, required this.user, required this.doctor});
  final Map<String, dynamic> user;
  final Map<String, dynamic> doctor;

  @override
  State<CreateConsultationScreen> createState() => _CreateConsultationScreenState();
}
class _CreateConsultationScreenState extends State<CreateConsultationScreen> {
  int? selectedPetId;
  final complaintController = TextEditingController();
  final photoController = TextEditingController();

  Future<List<Map<String, dynamic>>> _pets() async {
    final db = await AppDatabase.instance.database;
    return db.query('pets', where: 'id_user = ?', whereArgs: [widget.user['id_user']]);
  }

  Future<void> _startConsultation() async {
    if (selectedPetId == null || complaintController.text.trim().isEmpty) {
      showMessage(context, 'Pilih hewan dan isi keluhan terlebih dahulu.');
      return;
    }
    final db = await AppDatabase.instance.database;
    final consultationId = await db.insert('consultations', {
      'id_user': widget.user['id_user'],
      'id_doctor': widget.doctor['id_doctor'],
      'id_pet': selectedPetId,
      'complaint': complaintController.text.trim(),
      'complaint_photo': photoController.text.trim(),
      'consultation_date': nowIso(),
      'status': 'berjalan',
      'total_fee': widget.doctor['consultation_fee'],
    });
    await db.insert('payments', {
      'id_user': widget.user['id_user'],
      'payment_type': 'konsultasi',
      'reference_id': consultationId,
      'payment_method': 'Simulasi Transfer',
      'total_payment': widget.doctor['consultation_fee'],
      'payment_status': 'berhasil',
      'payment_date': nowIso(),
    });
    await db.insert('consultation_messages', {
      'id_consultation': consultationId,
      'sender_id': widget.user['id_user'],
      'message': complaintController.text.trim(),
      'attachment': photoController.text.trim(),
      'sent_at': nowIso(),
    });
    await db.insert('notifications', {
      'id_user': widget.user['id_user'],
      'title': 'Konsultasi dimulai',
      'message': 'Pembayaran simulasi berhasil. Konsultasi dengan ${widget.doctor['name']} berjalan.',
      'is_read': 0,
      'created_at': nowIso(),
    });
    if (!mounted) return;
    showMessage(context, 'Pembayaran simulasi berhasil. Konsultasi dimulai.');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user, consultationId: consultationId)));
  }

  @override
  void dispose() {
    complaintController.dispose();
    photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Form Konsultasi',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pets(),
        builder: (context, snapshot) {
          final pets = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              InfoBox(
                title: widget.doctor['name'] as String,
                body: '${widget.doctor['specialization']}\nBiaya konsultasi: ${money(widget.doctor['consultation_fee'] as num)}',
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: selectedPetId,
                decoration: const InputDecoration(labelText: 'Pilih Hewan'),
                items: pets.map((p) => DropdownMenuItem<int>(value: p['id_pet'] as int, child: Text('${p['pet_name']} - ${p['animal_type']}'))).toList(),
                onChanged: (value) => setState(() => selectedPetId = value),
              ),
              const SizedBox(height: 12),
              TextField(controller: complaintController, decoration: const InputDecoration(labelText: 'Keluhan Hewan'), maxLines: 4),
              const SizedBox(height: 12),
              TextField(controller: photoController, decoration: const InputDecoration(labelText: 'Path foto/lampiran (opsional)')),
              const SizedBox(height: 18),
              ElevatedButton.icon(onPressed: _startConsultation, icon: const Icon(Icons.payment), label: const Text('Bayar Simulasi & Mulai Chat')),
              if (pets.isEmpty) ...[
                const SizedBox(height: 12),
                const InfoBox(title: 'Belum ada hewan', body: 'Tambahkan data hewan terlebih dahulu pada menu Data Hewan.'),
              ],
            ],
          );
        },
      ),
    );
  }
}

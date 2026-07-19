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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user, required this.consultationId});
  final Map<String, dynamic> user;
  final int consultationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  Future<Map<String, dynamic>> _load() async {
    final db = await AppDatabase.instance.database;
    final consultations = await db.rawQuery('''
      SELECT c.*, p.pet_name, p.animal_type, owner.name AS owner_name, doctorUser.name AS doctor_name, doctorUser.id_user AS doctor_user_id
      FROM consultations c
      JOIN pets p ON p.id_pet = c.id_pet
      JOIN users owner ON owner.id_user = c.id_user
      JOIN doctors d ON d.id_doctor = c.id_doctor
      JOIN users doctorUser ON doctorUser.id_user = d.id_user
      WHERE c.id_consultation = ?
    ''', [widget.consultationId]);
    final messages = await db.rawQuery('''
      SELECT m.*, u.name AS sender_name, u.role
      FROM consultation_messages m
      JOIN users u ON u.id_user = m.sender_id
      WHERE m.id_consultation = ?
      ORDER BY m.id_message ASC
    ''', [widget.consultationId]);
    final records = await db.query('medical_records', where: 'id_consultation = ?', whereArgs: [widget.consultationId], limit: 1);
    return {'consultation': consultations.first, 'messages': messages, 'record': records.isEmpty ? null : records.first};
  }

  Future<void> _send() async {
    if (messageController.text.trim().isEmpty) return;
    final db = await AppDatabase.instance.database;
    await db.insert('consultation_messages', {
      'id_consultation': widget.consultationId,
      'sender_id': widget.user['id_user'],
      'message': messageController.text.trim(),
      'attachment': '',
      'sent_at': nowIso(),
    });
    messageController.clear();
    setState(() {});
  }

  Future<void> _createRecord(Map<String, dynamic> consultation) async {
    final note = TextEditingController();
    final summary = TextEditingController();
    final recommendation = TextEditingController();
    final medicine = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Rekam Medis'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: note, decoration: const InputDecoration(labelText: 'Catatan Dokter'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: summary, decoration: const InputDecoration(labelText: 'Ringkasan Kondisi'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: recommendation, decoration: const InputDecoration(labelText: 'Rekomendasi'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: medicine, decoration: const InputDecoration(labelText: 'Saran Obat'), maxLines: 2),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final db = await AppDatabase.instance.database;
              await db.insert('medical_records', {
                'id_consultation': widget.consultationId,
                'id_pet': consultation['id_pet'],
                'doctor_note': note.text.trim(),
                'condition_summary': summary.text.trim(),
                'recommendation': recommendation.text.trim(),
                'medicine_suggestion': medicine.text.trim(),
                'record_date': nowIso(),
              });
              await db.update('consultations', {'status': 'selesai'}, where: 'id_consultation = ?', whereArgs: [widget.consultationId]);
              await db.insert('notifications', {
                'id_user': consultation['id_user'],
                'title': 'Konsultasi selesai',
                'message': 'Dokter telah menambahkan rekam medis untuk ${consultation['pet_name']}.',
                'is_read': 0,
                'created_at': nowIso(),
              });
              if (mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    note.dispose();
    summary.dispose();
    recommendation.dispose();
    medicine.dispose();
  }

  Future<void> _review(Map<String, dynamic> consultation) async {
    int rating = 5;
    final comment = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Beri Ulasan'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              value: rating,
              decoration: const InputDecoration(labelText: 'Rating'),
              items: [1, 2, 3, 4, 5].map((r) => DropdownMenuItem(value: r, child: Text('$r bintang'))).toList(),
              onChanged: (v) => setLocal(() => rating = v ?? 5),
            ),
            const SizedBox(height: 8),
            TextField(controller: comment, decoration: const InputDecoration(labelText: 'Komentar'), maxLines: 2),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final db = await AppDatabase.instance.database;
                final existing = await db.query('reviews', where: 'id_consultation = ?', whereArgs: [widget.consultationId], limit: 1);
                if (existing.isEmpty) {
                  await db.insert('reviews', {
                    'id_user': widget.user['id_user'],
                    'id_doctor': consultation['id_doctor'],
                    'id_consultation': widget.consultationId,
                    'rating': rating,
                    'comment': comment.text.trim(),
                    'review_date': nowIso(),
                  });
                  final avg = await db.rawQuery('SELECT AVG(rating) AS avg_rating FROM reviews WHERE id_doctor = ?', [consultation['id_doctor']]);
                  await db.update('doctors', {'rating': (avg.first['avg_rating'] as num?)?.toDouble() ?? rating.toDouble()}, where: 'id_doctor = ?', whereArgs: [consultation['id_doctor']]);
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
    comment.dispose();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Chat Konsultasi',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final consultation = snapshot.data!['consultation'] as Map<String, dynamic>;
          final messages = (snapshot.data!['messages'] as List).cast<Map<String, dynamic>>();
          final record = snapshot.data!['record'] as Map<String, dynamic>?;
          final isDoctor = widget.user['role'] == 'dokter';
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.warmCream.withOpacity(0.7), borderRadius: BorderRadius.circular(18)),
                child: Text('Hewan: ${consultation['pet_name']} (${consultation['animal_type']})\nPemilik: ${consultation['owner_name']}\nDokter: ${consultation['doctor_name']}\nStatus: ${consultation['status']}'),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final mine = m['sender_id'] == widget.user['id_user'];
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.lightBlue : AppColors.warmCream,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m['sender_name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                          const SizedBox(height: 4),
                          Text(m['message'] as String),
                          if ((m['attachment'] as String?)?.isNotEmpty == true) Text('Lampiran: ${m['attachment']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              if (record != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: InfoBox(title: 'Rekam Medis Tersimpan', body: 'Ringkasan: ${record['condition_summary']}\nRekomendasi: ${record['recommendation']}'),
                ),
              if (isDoctor && record == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _createRecord(consultation), icon: const Icon(Icons.save), label: const Text('Selesaikan & Buat Rekam Medis'))),
                ),
              if (!isDoctor && consultation['status'] == 'selesai')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _review(consultation), icon: const Icon(Icons.star), label: const Text('Beri Rating Dokter'))),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Row(children: [
                    Expanded(child: TextField(controller: messageController, decoration: const InputDecoration(hintText: 'Tulis pesan...'))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _send, child: const Icon(Icons.send)),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.doctor});
  final Map<String, Object?> doctor;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Map<String, Object?>> pets = [];
  List<Map<String, Object?>> schedules = [];
  int? petId, scheduleId;
  String? selectedDate;
  String consultationMethod = 'Chat';
  final complaint = TextEditingController();
  bool loading = true;
  bool isSubmitting = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final owner = context.read<AuthProvider>().user!.id;
    pets = await DatabaseHelper.instance.getPets(owner);
    schedules =
        await DatabaseHelper.instance.getSchedules(widget.doctor['id'] as int);
    if (pets.isNotEmpty) petId = pets.first['id'] as int;

    final availableSchedules =
        schedules.where((s) => s['status'] == 'available').toList();
    if (availableSchedules.isNotEmpty) {
      selectedDate = availableSchedules.first['date'] as String;
    }

    setState(() => loading = false);
  }

  Future<void> submit() async {
    final consultationArgs =
        widget.doctor['consultationArgs'] as Map<String, dynamic>?;
    final provider = context.read<ConsultationProvider>();
    final isControl = widget.doctor['is_control'] as int? ?? 0;
    final parentConsultationId =
        widget.doctor['parent_consultation_id'] as int?;

    if (consultationArgs == null) {
      if (petId == null ||
          scheduleId == null ||
          complaint.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lengkapi hewan, jadwal, dan keluhan.')));
        return;
      }
    } else {
      if (scheduleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih jadwal terlebih dahulu.')));
        return;
      }
    }

    setState(() => isSubmitting = true);

    try {
      int newConsultationId;
      if (consultationArgs == null) {
        // Legacy path
        newConsultationId = await provider.create(
            petId: petId!,
            doctorId: int.parse(widget.doctor['id'].toString()),
            scheduleId: scheduleId!,
            complaint: complaint.text,
            method: consultationMethod);
      } else {
        newConsultationId = await provider.createControlConsultation(
            petId: int.parse(consultationArgs['pet_id'].toString()),
            doctorId: int.parse(widget.doctor['id'].toString()),
            scheduleId: scheduleId!,
            complaint: consultationArgs['complaint'] as String,
            method: consultationMethod,
            complaintData:
                consultationArgs['complaint_data'] as Map<String, dynamic>,
            screeningData:
                consultationArgs['screening_data'] as Map<String, dynamic>,
            parentConsultationId: parentConsultationId ?? 0);
      }

      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.payment, arguments: {
          'consultationId': newConsultationId,
          'doctor': widget.doctor,
          'method': consultationMethod
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, Object?>>> groupedSchedules = {};
    for (var s in schedules.where((s) => s['status'] == 'available')) {
      final date = s['date'] as String;
      groupedSchedules.putIfAbsent(date, () => []).add(s);
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Booking konsultasi')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(padding: const EdgeInsets.all(20), children: [
                InfoCard(
                    child: Row(children: [
                  AvatarInitials('${widget.doctor['name']}',
                      icon: Icons.medical_services),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('${widget.doctor['name']}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        Text('${widget.doctor['specialist']}',
                            style: const TextStyle(color: AppColors.muted))
                      ]))
                ])),
                const SizedBox(height: 18),
                if (widget.doctor['consultationArgs'] == null) ...[
                  DropdownButtonFormField<int>(
                      value: petId,
                      decoration:
                          const InputDecoration(labelText: 'Pilih hewan'),
                      items: pets
                          .map((p) => DropdownMenuItem(
                              value: p['id'] as int,
                              child: Text('${p['name']} (${p['species']})')))
                          .toList(),
                      onChanged: (v) => setState(() => petId = v)),
                  const SizedBox(height: 14),
                ],
                if (groupedSchedules.isEmpty)
                  const Text('Tidak ada jadwal tersedia',
                      style: TextStyle(color: Colors.red))
                else ...[
                  const Text('Pilih Tanggal',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: groupedSchedules.keys.map((date) {
                        final isSelected = selectedDate == date;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(date),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedDate = date;
                                scheduleId = null;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedDate != null) ...[
                    const Text('Pilih Jam',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: groupedSchedules[selectedDate]!.map((s) {
                        final isSelected = scheduleId == s['id'];
                        return ChoiceChip(
                          label: Text(s['time'] as String),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              scheduleId = s['id'] as int;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
                const SizedBox(height: 14),
                if (widget.doctor['consultationArgs'] == null) ...[
                  TextField(
                      controller: complaint,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: 'Keluhan utama',
                          alignLabelWithHint: true)),
                  const SizedBox(height: 24),
                ],
                DropdownButtonFormField<String>(
                    value: consultationMethod,
                    decoration:
                        const InputDecoration(labelText: 'Metode Konsultasi'),
                    items: ['Chat', 'Voice Call', 'Video Call']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => consultationMethod = v ?? 'Chat')),
                const SizedBox(height: 24),
                isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: submit,
                        child: const Text('Lanjut ke Pembayaran'))
              ]));
  }
}

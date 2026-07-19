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

class OwnerConsultationsScreen extends StatefulWidget {
  const OwnerConsultationsScreen({super.key});
  @override
  State<OwnerConsultationsScreen> createState() =>
      _OwnerConsultationsScreenState();
}

class _OwnerConsultationsScreenState extends State<OwnerConsultationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<ConsultationProvider>()
        .loadOwner(context.read<AuthProvider>().user!.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConsultationProvider>();
    return OwnerScaffold(
        title: 'Konsultasi',
        index: 3,
        body: p.loading
            ? const Center(child: CircularProgressIndicator())
            : p.items.isEmpty
                ? const EmptyState(
                    title: 'Belum ada konsultasi',
                    message: 'Pilih dokter dan jadwal untuk memulai.',
                    icon: Icons.chat_bubble_outline)
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: p.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = p.items[i];
                      return InfoCard(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(children: [
                              Expanded(
                                  child: Text('${c['doctor_name']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 17))),
                              StatusChip('${c['status']}')
                            ]),
                            const SizedBox(height: 8),
                            Text(
                                '${c['pet_name']} • ${c['schedule_date'] ?? '-'} ${c['schedule_time'] ?? ''}',
                                style: const TextStyle(color: AppColors.muted)),
                            const SizedBox(height: 8),
                            Text('${c['complaint']}',
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            if (c['status'] == 'waiting_payment') ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.payment,
                                      arguments: {
                                        'consultationId': c['id'],
                                        'doctor': {'name': c['doctor_name']},
                                        'method': c['method'] ?? 'Chat',
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                child: const Text('Bayar Sekarang',
                                    style: TextStyle(color: Colors.white)),
                              )
                            ] else if (c['status'] == 'scheduled') ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.consultationPrep,
                                      arguments: c);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                child: const Text('Persiapan Konsultasi',
                                    style: TextStyle(color: Colors.white)),
                              )
                            ] else if (c['status'] == 'in_progress' ||
                                c['status'] == 'accepted') ...[
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.consultationRoom,
                                      arguments: c);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  minimumSize: const Size(double.infinity, 36),
                                ),
                                child: const Text('Masuk Ruang Konsultasi',
                                    style: TextStyle(color: Colors.white)),
                              )
                            ] else if (c['status'] == 'finished') ...[
                              const SizedBox(height: 12),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, AppRoutes.consultationResult,
                                        arguments: c),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFF45A5C7)),
                                      minimumSize:
                                          const Size(double.infinity, 36),
                                    ),
                                    child: const Text('Hasil',
                                        style: TextStyle(
                                            color: Color(0xFF45A5C7))),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, AppRoutes.monitoringLog,
                                        arguments: c),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F2646),
                                      minimumSize:
                                          const Size(double.infinity, 36),
                                    ),
                                    child: const Text('Monitoring',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ]),
                              if (c['review_id'] == null) ...[
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.reviewForm,
                                        arguments: c);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    minimumSize:
                                        const Size(double.infinity, 36),
                                  ),
                                  child: const Text('Beri Ulasan',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ]
                            ]
                          ]));
                    }));
  }
}

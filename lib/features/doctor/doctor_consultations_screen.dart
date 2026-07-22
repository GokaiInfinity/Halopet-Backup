import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context
        .read<ConsultationProvider>()
        .loadDoctor(context.read<AuthProvider>().user!.id));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ConsultationProvider>();

    return DoctorScaffold(
      title: 'Konsultasi',
      index: 0, 
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.items.isEmpty
              ? const EmptyState(
                  title: 'Belum ada konsultasi',
                  message: 'Tidak ada sesi konsultasi saat ini.',
                  icon: Icons.chat_bubble_outline)
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: p.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = p.items[i];
                    final status = c['status'] as String;
                    final startTimeStr = c['start_time'] as String?;
                    final dateStr = startTimeStr != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(startTimeStr))
                        : '-';
                    
                    final ownerName = c['owner_name'] as String? ?? 'Pemilik';
                    final petName = c['pet_name'] as String? ?? 'Hewan';

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ownerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F2646)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'COMPLETED'
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'COMPLETED'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$petName • $dateStr',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF7A93AA)),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: status == 'IN_PROGRESS' || status == 'ACCEPTED'
                                    ? () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.consultationRoom,
                                            arguments: {'consultation_id': c['id']});
                                      }
                                    : null,
                                child: Text(status == 'IN_PROGRESS' || status == 'ACCEPTED' ? 'Masuk Ruang Konsultasi' : 'Selesai'),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

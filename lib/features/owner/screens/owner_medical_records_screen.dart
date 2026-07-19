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

class OwnerMedicalRecordsScreen extends StatelessWidget {
  const OwnerMedicalRecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final id = context.read<AuthProvider>().user!.id;
    return Scaffold(
        appBar: AppBar(title: const Text('Rekam medis')),
        body: FutureBuilder<List<Map<String, Object?>>>(
            future: DatabaseHelper.instance.getMedicalRecordsForOwner(id),
            builder: (_, s) {
              if (!s.hasData)
                return const Center(child: CircularProgressIndicator());
              final items = s.data!;
              if (items.isEmpty)
                return const EmptyState(
                    title: 'Belum ada rekam medis',
                    message:
                        'Rekam medis akan muncul setelah konsultasi selesai.',
                    icon: Icons.medical_information_outlined);
              return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = items[i];
                    final date = DateTime.tryParse('${r['date']}');
                    return InfoCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            Expanded(
                                child: Text('${r['pet_name']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900))),
                            Text(
                                date == null
                                    ? ''
                                    : DateFormat('dd MMM yyyy').format(date),
                                style: const TextStyle(color: AppColors.muted))
                          ]),
                          const SizedBox(height: 10),
                          Text('${r['diagnosis']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text('Dokter: ${r['doctor_name']}',
                              style: const TextStyle(color: AppColors.muted)),
                          if ('${r['medicine']}'.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text('Obat: ${r['medicine']}')
                          ],
                          if ('${r['notes']}'.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('Catatan: ${r['notes']}')
                          ]
                        ]));
                  });
            }));
  }
}

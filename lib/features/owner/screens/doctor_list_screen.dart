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

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key, this.consultationArgs});
  final Map<String, dynamic>? consultationArgs;
  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String searchQuery = '';
  String? selectedSpecialist;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<DoctorProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DoctorProvider>();
    return OwnerScaffold(
        title: 'Cari dokter',
        index: 2,
        body: p.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFF45A5C7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (val) => setState(() => searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Cari dokter atau spesialis...',
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF7A93AA)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 0),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.tune,
                                  color: Color(0xFF45A5C7)),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: p.doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = p.doctors[index];
                        final name = doctor['name'] as String;
                        final spec = doctor['specialist'] as String;

                        if (searchQuery.isNotEmpty &&
                            !name
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) &&
                            !spec
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase())) {
                          return const SizedBox();
                        }

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE6F4F8))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: AvatarInitials(name,
                                radius: 29, icon: Icons.medical_services),
                            title: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(spec,
                                    style: const TextStyle(
                                        color: Color(0xFF7A93AA))),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFC107), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                        '${doctor['rating']} (${doctor['experience']} thn)',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Tersedia',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                    'Rp ${doctor['consultation_fee'] ?? 50000}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                              ],
                            ),
                            onTap: () {
                              final doctorData =
                                  Map<String, Object?>.from(doctor);
                              if (widget.consultationArgs != null) {
                                doctorData['consultationArgs'] =
                                    widget.consultationArgs;
                              }
                              Navigator.pushNamed(
                                  context, AppRoutes.doctorDetail,
                                  arguments: doctorData);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ));
  }
}

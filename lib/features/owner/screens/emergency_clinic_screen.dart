import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../providers/consultation_provider.dart';
import '../../../database/database_helper.dart';

class EmergencyClinicScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const EmergencyClinicScreen({super.key, required this.args});

  @override
  State<EmergencyClinicScreen> createState() => _EmergencyClinicScreenState();
}

class _EmergencyClinicScreenState extends State<EmergencyClinicScreen> {
  bool isSubmitting = false;

  Future<void> _submitEmergencyVisit() async {
    setState(() => isSubmitting = true);
    try {
      final provider = context.read<ConsultationProvider>();

      // We need a doctor ID to create the consultation. 
      // We'll fetch the first available doctor (or use a dummy ID like 1 if empty)
      final doctors = await DatabaseHelper.instance.getDoctors();
      int doctorId = doctors.isNotEmpty ? doctors.first['id'] as int : 1;

      // Create consultation
      await provider.createWithDetails(
        petId: widget.args['pet_id'] as int,
        doctorId: doctorId,
        scheduleId: 0, // No specific schedule
        complaint: widget.args['complaint'] as String,
        method: 'Kunjungan Darurat',
        complaintData: widget.args['complaint_data'] as Map<String, dynamic>,
        screeningData: widget.args['screening_data'] as Map<String, dynamic>,
      );

      if (!mounted) return;
      
      // Show success and redirect to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunjungan darurat dicatat. Silakan segera menuju klinik!'),
          backgroundColor: Colors.red,
        ),
      );

      // Navigate back to owner dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.ownerHome,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // Light red background
      appBar: AppBar(
        title: const Text('Kondisi Darurat', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Kondisi Hewan Anda Darurat!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Berdasarkan gejala yang dipilih, hewan Anda membutuhkan penanganan medis secepatnya. Jangan menunggu, segera bawa hewan Anda ke klinik terdekat kami.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0F2646),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_hospital, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Klinik Utama Halopet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F2646),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Color(0xFF7A93AA), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Jl. Darurat No.1, Kebayoran Baru, Jakarta Selatan',
                            style: TextStyle(fontSize: 14, color: Color(0xFF0F2646)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.phone, color: Color(0xFF7A93AA), size: 20),
                        SizedBox(width: 8),
                        Text(
                          '0812-3456-7890',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF45A5C7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                '*Sistem akan mencatat kunjungan Anda untuk kemudahan administrasi & pembayaran nanti.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitEmergencyVisit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Menuju Klinik Sekarang',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

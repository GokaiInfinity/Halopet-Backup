import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:halopet_mobile/providers/auth_provider.dart';
import 'package:halopet_mobile/database/database_helper.dart';
import 'package:halopet_mobile/features/owner/screens/owner_prescription_detail_screen.dart';

class OwnerPrescriptionListScreen extends StatefulWidget {
  const OwnerPrescriptionListScreen({super.key});

  @override
  _OwnerPrescriptionListScreenState createState() =>
      _OwnerPrescriptionListScreenState();
}

class _OwnerPrescriptionListScreenState
    extends State<OwnerPrescriptionListScreen> {
  late Future<List<Map<String, dynamic>>> _prescriptionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  void _fetchPrescriptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user!.id;
    setState(() {
      _prescriptionsFuture =
          DatabaseHelper.instance.getPrescriptionsByOwnerId(ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Resep Obat',
            style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _prescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan memuat data.'));
          }

          final prescriptions = snapshot.data ?? [];

          if (prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada resep obat.',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final p = prescriptions[index];
              return _buildPrescriptionCard(p);
            },
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> p) {
    final itemsCount = (p['items'] as List?)?.length ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerPrescriptionDetailScreen(prescription: p),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_information, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['pet_name'] ?? 'Hewan',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2646)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['prescription_date']?.toString().split(' ')[0] ?? '',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Oleh Dokter:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(
                          p['doctor_name'] ?? 'Dokter Hewan',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F2646)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$itemsCount Obat',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

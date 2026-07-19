import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/consultation_provider.dart';

// ==== MOCKUP 34: HASIL KONSULTASI ====
class ConsultationResultScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const ConsultationResultScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final doctorName = args['doctor_name'] ?? 'Drh. Anisa Putri';
    final doctorSpec = args['doctor_specialist'] ?? 'Kulit & Bulu';
    final cid = args['id'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2646)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hasil Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646))),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, Object?>?>(
          future:
              context.read<ConsultationProvider>().getConsultationResult(cid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E5EC)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFE6F4F8),
                          child: const Icon(Icons.person,
                              color: Color(0xFF45A5C7), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F2646))),
                              Text(doctorSpec,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF7A93AA))),
                              const SizedBox(height: 4),
                              const Text('Selesai',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFFB0C4D9))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('Selesai',
                              style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (data == null)
                    const Center(
                        child: Text('Hasil konsultasi belum tersedia.'))
                  else ...[
                    if (data['diagnosis'] != null &&
                        (data['diagnosis'] as String).isNotEmpty) ...[
                      _buildSectionTitle('Diagnosis Sementara'),
                      Text(data['diagnosis'] as String,
                          style: const TextStyle(color: Color(0xFF0F2646))),
                      const SizedBox(height: 16),
                    ],
                    if (data['advice'] != null &&
                        (data['advice'] as String).isNotEmpty) ...[
                      _buildSectionTitle('Saran Dokter'),
                      Text(data['advice'] as String,
                          style: const TextStyle(color: Color(0xFF0F2646))),
                      const SizedBox(height: 16),
                    ],
                    if (data['control_decision'] != null &&
                        (data['control_decision'] as String).isNotEmpty) ...[
                      _buildSectionTitle('Keputusan Kontrol'),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(data['control_decision'] as String,
                            style: const TextStyle(
                                color: Color(0xFFE65100),
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (data['warning_signs'] != null &&
                        (data['warning_signs'] as String).isNotEmpty) ...[
                      _buildSectionTitle('Tanda Bahaya'),
                      Text(data['warning_signs'] as String,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info,
                            color: Color(0xFF2196F3), size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                              'Ini adalah hasil konsultasi online. Jika kondisi memburuk, segera periksa ke klinik terdekat.',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF0F2646))),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.electronicPrescription,
                        arguments: args),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF45A5C7),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Lihat Resep',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Bukti Pembayaran
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F2646)),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Bukti Bayar',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2646))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // View Chat History - we can just route to chat screen as it will load old messages
                            Navigator.pushNamed(context, AppRoutes.chat,
                                arguments: args);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0F2646)),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Histori Chat',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2646))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to booking, pass doctor info and flag isControl
                      final doc = {
                        'id': data?['doctor_id'] ?? args['doctor_id'],
                        'name': doctorName,
                        'specialist': doctorSpec,
                        'parent_consultation_id': cid,
                        'is_control': 1
                      };
                      Navigator.pushNamed(context, AppRoutes.booking,
                          arguments: doc);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2646),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Jadwalkan Kontrol',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2646))),
    );
  }
}

// ==== MOCKUP 35: RESEP ELEKTRONIK ====
class ElectronicPrescriptionScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const ElectronicPrescriptionScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final doctorName = args['doctor_name'] ?? 'Drh. Anisa Putri';
    final petName = args['pet_name'] ?? 'Hewan Anda';
    final cid = args['id'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2646)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Resep Elektronik',
            style: TextStyle(color: Color(0xFF0F2646))),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
          future: context.read<ConsultationProvider>().getPrescription(cid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final rx = snapshot.data;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Resep
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE6F4F8),
                              child: const Icon(Icons.person,
                                  color: Color(0xFF45A5C7), size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(doctorName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F2646))),
                                  const Text('SIP: 1306/P/HK/0024',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF7A93AA))),
                                ],
                              ),
                            ),
                            const Icon(Icons.verified, color: Colors.green),
                          ],
                        ),
                        const Divider(height: 32, color: Color(0xFFE0E5EC)),
                        const Text('Pasien',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF7A93AA))),
                        const SizedBox(height: 4),
                        Text(petName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2646))),
                        const SizedBox(height: 24),

                        const Text('Obat yang Diresepkan',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2646))),
                        const SizedBox(height: 16),

                        if (rx == null || (rx['items'] as List).isEmpty)
                          const Text('Tidak ada obat yang diresepkan.')
                        else
                          ...(rx['items'] as List)
                              .map((item) => _buildMedicineItem(
                                  item['medicine_name'] ?? '',
                                  item['dose'] ?? '',
                                  item['qty'] ?? ''))
                              .toList(),

                        const SizedBox(height: 24),
                        if (rx != null &&
                            rx['notes'] != null &&
                            (rx['notes'] as String).isNotEmpty) ...[
                          const Text('Catatan Dokter',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F2646))),
                          const SizedBox(height: 8),
                          Text(rx['notes'],
                              style: const TextStyle(color: Color(0xFF0F2646))),
                          const SizedBox(height: 24),
                        ],

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info,
                                  color: Color(0xFF7A93AA), size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                    'Resep ini berlaku 7 hari sejak tanggal diterbitkan.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7A93AA))),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons Bottom
                if (rx != null && (rx['items'] as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.pharmacySelection,
                              arguments: args),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF45A5C7),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Beli Obat ke Apotek',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF0F2646)),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Unduh',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F2646))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF0F2646)),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Bagikan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F2646))),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
              ],
            );
          }),
    );
  }

  Widget _buildMedicineItem(String name, String dose, String qty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFE6F4F8),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.medication,
                color: Color(0xFF45A5C7), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
                Text(dose,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF7A93AA))),
              ],
            ),
          ),
          Text(qty,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF45A5C7))),
        ],
      ),
    );
  }
}

// ==== MOCKUP 36: PEMBELIAN OBAT ====
class PharmacySelectionScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const PharmacySelectionScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final pharmacies = [
      {
        'name': 'Apotek Hewan Sehat',
        'dist': '1.2 km',
        'rating': '4.8',
        'color': Colors.green
      },
      {
        'name': 'Apotek PetCare',
        'dist': '2.1 km',
        'rating': '4.7',
        'color': Colors.blue
      },
      {
        'name': 'Apotek Mutiara',
        'dist': '2.6 km',
        'rating': '4.6',
        'color': Colors.purple
      },
      {
        'name': 'Apotek Sahabat',
        'dist': '3.3 km',
        'rating': '4.5',
        'color': Colors.red
      },
      {
        'name': 'Pet Pharmacy 24',
        'dist': '3.8 km',
        'rating': '4.7',
        'color': Colors.orange
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2646)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pembelian Obat',
            style: TextStyle(color: Color(0xFF0F2646))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kirim resep ke apotek',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            const Text('Pilih apotek untuk memproses resep secara online.',
                style: TextStyle(color: Color(0xFF7A93AA))),
            const SizedBox(height: 24),
            ...pharmacies.map((p) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE0E5EC)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: (p['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        Icon(Icons.local_pharmacy, color: p['color'] as Color),
                  ),
                  title: Text(p['name'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFFC107), size: 14),
                      const SizedBox(width: 4),
                      Text('${p['rating']} • ${p['dist']}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF7A93AA))),
                    ],
                  ),
                  trailing:
                      const Icon(Icons.chevron_right, color: Color(0xFFB0C4D9)),
                  onTap: () async {
                    final provider = context.read<ConsultationProvider>();
                    final cid = args['id'] as int? ?? 0;
                    if (cid != 0) {
                      // dummy price
                      await provider.createMedicineOrder(
                          cid, 'Alamat dummy', 150000, 15000);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Pesanan berhasil dibuat di ${p['name']}')));
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.ownerHome);
                  },
                ),
              );
            }),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Lihat semua apotek',
                    style: TextStyle(
                        color: Color(0xFF45A5C7), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
                child: Text('Atau kirim resep manual',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2646)))),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message, color: Colors.green),
              label: const Text('Kirim via WhatsApp',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/consultation_provider.dart';
import '../../utils/pdf_prescription_generator.dart';

// ==== MOCKUP 34: HASIL KONSULTASI ====
class ConsultationResultScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const ConsultationResultScreen({super.key, required this.args});

  @override
  State<ConsultationResultScreen> createState() => _ConsultationResultScreenState();
}

class _ConsultationResultScreenState extends State<ConsultationResultScreen> {
  bool _isPaid = false;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final doctorName = args['doctor_name'] ?? 'Dokter';
    final doctorSpec = args['doctor_specialist'] ?? 'Kulit & Bulu';
    final cid = args['id'] as int? ?? 0;

    final isEmergency = args['is_emergency'] == true;
    final canPop = !isEmergency || _isPaid;

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selesaikan pembayaran darurat terlebih dahulu.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2646)),
            onPressed: () {
              if (canPop) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selesaikan pembayaran darurat terlebih dahulu.')),
                );
              }
            },
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
                  if (isEmergency) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: _isPaid ? Colors.green.shade50 : Colors.red.shade50,
                        border: Border.all(color: _isPaid ? Colors.green : Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isPaid ? Icons.check_circle : Icons.warning_rounded,
                                color: _isPaid ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPaid ? 'Tagihan UGD Lunas' : 'Tagihan UGD Belum Dibayar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isPaid ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPaid 
                                ? 'Terima kasih telah menyelesaikan pembayaran.' 
                                : 'Sesi darurat telah berakhir. Harap selesaikan pembayaran sebesar Rp 150.000 agar dapat kembali ke beranda.',
                            style: TextStyle(color: _isPaid ? Colors.green.shade900 : Colors.red.shade900),
                          ),
                          if (!_isPaid) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Simulate payment
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const AlertDialog(
                                    content: Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 16),
                                        Text('Memproses pembayaran...'),
                                      ],
                                    ),
                                  ),
                                );
                                Future.delayed(const Duration(seconds: 2), () {
                                  Navigator.pop(context); // Close loading
                                  setState(() => _isPaid = true);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                minimumSize: const Size(double.infinity, 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Bayar Tagihan Rp 150.000', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
      ),
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
    final doctorName = args['doctor_name'] ?? 'Dokter';
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
                                onPressed: () async {
                                  await PdfPrescriptionGenerator.generateAndSharePrescription(
                                    consultationId: cid,
                                    doctorName: doctorName,
                                    petName: petName,
                                    items: rx['items'] as List,
                                    notes: rx['notes'] as String?,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF0F2646)),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Unduh / Bagikan PDF',
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
                  onTap: () {
                    final newArgs = Map<String, dynamic>.from(args);
                    newArgs['pharmacy'] = p;
                    Navigator.pushNamed(
                        context, AppRoutes.medicineCheckout, arguments: newArgs);
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

// ==== MEDICINE CHECKOUT SCREEN ====
class MedicineCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const MedicineCheckoutScreen({super.key, required this.args});

  @override
  State<MedicineCheckoutScreen> createState() => _MedicineCheckoutScreenState();
}

class _MedicineCheckoutScreenState extends State<MedicineCheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmacy = widget.args['pharmacy'] as Map<String, dynamic>? ?? {};
    final cid = widget.args['id'] as int? ?? 0;
    final pharmacyName = pharmacy['name'] ?? 'Apotek';
    final deliveryDistance = pharmacy['dist'] ?? '0 km';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Checkout Obat', style: TextStyle(color: Color(0xFF0F2646))),
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: context.read<ConsultationProvider>().getPrescription(cid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rx = snapshot.data;
          final items = (rx?['items'] as List?) ?? [];
          
          // Dummy calculation for medicine total (let's assume 50000 per item for mockup)
          final medTotal = items.length * 50000;
          final deliveryFee = 15000;
          final total = medTotal + deliveryFee;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Apotek Pilihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_pharmacy, color: Colors.blue, size: 32),
                  title: Text(pharmacyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Jarak pengiriman: $deliveryDistance'),
                ),
                const Divider(height: 32),
                
                const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Masukkan alamat lengkap beserta patokan rumah...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const Divider(height: 32),

                const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item['medicine_name']} (${item['qty']})')),
                      const Text('Rp 50000'),
                    ],
                  ),
                )).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ongkos Kirim', style: TextStyle(color: Color(0xFF7A93AA))),
                    Text('Rp $deliveryFee', style: const TextStyle(color: Color(0xFF7A93AA))),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Rp $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () {
                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat pengiriman tidak boleh kosong!')));
                      return;
                    }
                    final provider = context.read<ConsultationProvider>();
                    if (cid != 0) {
                      provider.createMedicineOrder(cid, _addressController.text, medTotal.toDouble(), deliveryFee.toDouble());
                    }
                    final newArgs = Map<String, dynamic>.from(widget.args);
                    newArgs['total'] = total;
                    Navigator.pushNamed(context, AppRoutes.medicinePayment, arguments: newArgs);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45A5C7),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

// ==== MEDICINE PAYMENT SCREEN ====
class MedicinePaymentScreen extends StatefulWidget {
  final Map<String, dynamic> args;
  const MedicinePaymentScreen({super.key, required this.args});

  @override
  State<MedicinePaymentScreen> createState() => _MedicinePaymentScreenState();
}

class _MedicinePaymentScreenState extends State<MedicinePaymentScreen> {
  String selectedMethod = 'Transfer Bank';

  @override
  Widget build(BuildContext context) {
    final total = widget.args['total'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Pembayaran', style: TextStyle(color: Color(0xFF0F2646))),
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Tagihan', style: TextStyle(color: Color(0xFF7A93AA))),
            const SizedBox(height: 8),
            Text('Rp $total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...['Transfer Bank', 'Virtual Account BCA', 'GoPay', 'OVO'].map((m) {
              return RadioListTile(
                title: Text(m),
                value: m,
                groupValue: selectedMethod,
                onChanged: (val) {
                  setState(() => selectedMethod = val.toString());
                },
              );
            }).toList(),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                Future.delayed(const Duration(seconds: 2), () async {
                  Navigator.pop(context); // close dialog
                  final cid = widget.args['id'] as int? ?? 0;
                  final order = await DatabaseHelper.instance.getMedicineOrder(cid);
                  if (order != null) {
                    await DatabaseHelper.instance.updateMedicineOrderStatus(order['id'] as int, 'processing');
                  }
                  
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.medicineTracker, arguments: widget.args);
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF45A5C7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== MEDICINE TRACKER SCREEN ====
class MedicineTrackerScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const MedicineTrackerScreen({super.key, required this.args});

  Widget _buildStep(String title, String subtitle, bool isActive, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isActive ? Colors.blue : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isActive ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: isActive ? Colors.blue : Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cid = args['id'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Pelacakan Pesanan', style: TextStyle(color: Color(0xFF0F2646))),
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.ownerHome, (route) => false),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseHelper.instance.getMedicineOrder(cid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) return const Center(child: Text('Pesanan tidak ditemukan.'));

          final status = order['status'] as String;
          int step = 0;
          if (status == 'waiting_payment') step = 0;
          if (status == 'processing') step = 1;
          if (status == 'shipping') step = 2;
          if (status == 'delivered') step = 3;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildStep('Pesanan Dibuat', 'Pesanan telah diterima dan menunggu pembayaran.', step >= 0, false),
                _buildStep('Diproses Apotek', 'Apotek sedang menyiapkan obat Anda.', step >= 1, false),
                _buildStep('Sedang Dikirim', 'Kurir sedang dalam perjalanan ke alamat Anda.', step >= 2, false),
                _buildStep('Selesai', 'Obat telah sampai di tujuan.', step >= 3, true),
                
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.ownerConsultations, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

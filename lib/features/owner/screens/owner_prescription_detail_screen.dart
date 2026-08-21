import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class OwnerPrescriptionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> prescription;

  const OwnerPrescriptionDetailScreen({Key? key, required this.prescription}) : super(key: key);

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy HH:mm').format(dt);
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = (prescription['items'] as List?) ?? [];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detail Resep',
            style: TextStyle(color: Color(0xFF0F2646), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
            tooltip: 'Export ke PDF',
            onPressed: () => _exportToPdf(context, items),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resep Obat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.8)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Hewan:', prescription['pet_name'] ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Dokter:', prescription['doctor_name'] ?? '-'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Tanggal:', _formatDate(prescription['prescription_date']?.toString())),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Medicine List
            const Text(
              'Daftar Obat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646)),
            ),
            const SizedBox(height: 12),
            
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Tidak ada obat dalam resep ini.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...items.map((item) => _buildMedicineItem(item)).toList(),

            const SizedBox(height: 24),

            // Additional Notes
            const Text(
              'Catatan Dokter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646)),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                (prescription['notes'] != null && prescription['notes'].toString().isNotEmpty) 
                  ? prescription['notes'] 
                  : 'Tidak ada catatan tambahan.',
                style: TextStyle(
                  color: (prescription['notes'] != null && prescription['notes'].toString().isNotEmpty) ? Colors.black87 : Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildMedicineItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medication, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['medicine_name'] ?? 'Obat',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2646)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item['form'] ?? '-'} • ${item['qty'] ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            _buildDetailRow('Dosis', item['dose']),
            const SizedBox(height: 8),
            _buildDetailRow('Frekuensi', item['frequency']),
            const SizedBox(height: 8),
            _buildDetailRow('Durasi', item['duration']),
            const SizedBox(height: 8),
            _buildDetailRow('Cara Pakai', item['method']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(
            (value != null && value.toString().isNotEmpty) ? value.toString() : '-',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Future<void> _exportToPdf(BuildContext context, List<dynamic> items) async {
    final pdf = pw.Document();
    
    final dateStr = prescription['prescription_date']?.toString().split(' ')[0] ?? '-';
    final petName = prescription['pet_name'] ?? '-';
    final doctorName = prescription['doctor_name'] ?? '-';
    final notes = (prescription['notes'] != null && prescription['notes'].toString().isNotEmpty) 
                  ? prescription['notes'] 
                  : 'Tidak ada catatan tambahan.';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('HALOPET', style: pw.TextStyle(color: PdfColors.blue, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('RESEP OBAT', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ]
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Info Resep
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 80, child: pw.Text('Pasien (Hewan):', style: pw.TextStyle(color: PdfColors.grey700))),
                      pw.Text(petName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Container(width: 80, child: pw.Text('Dokter Hewan:', style: pw.TextStyle(color: PdfColors.grey700))),
                      pw.Text(doctorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Container(width: 80, child: pw.Text('Tanggal:', style: pw.TextStyle(color: PdfColors.grey700))),
                      pw.Text(dateStr, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  ),
                ]
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Daftar Obat
            pw.Text('Daftar Obat', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 10),
            
            if (items.isEmpty)
              pw.Text('Tidak ada obat dalam resep ini.', style: const pw.TextStyle(color: PdfColors.grey))
            else
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 12),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          item['medicine_name'] ?? 'Obat', 
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Bentuk: ${item['form'] ?? '-'} | Qty: ${item['qty'] ?? '-'}', style: pw.TextStyle(color: PdfColors.grey700)),
                        pw.Divider(color: PdfColors.grey200),
                        pw.Row(
                          children: [
                            pw.Container(width: 70, child: pw.Text('Dosis:', style: pw.TextStyle(color: PdfColors.grey700))),
                            pw.Expanded(child: pw.Text('${item['dose'] ?? '-'}')),
                          ]
                        ),
                        pw.Row(
                          children: [
                            pw.Container(width: 70, child: pw.Text('Frekuensi:', style: pw.TextStyle(color: PdfColors.grey700))),
                            pw.Expanded(child: pw.Text('${item['frequency'] ?? '-'}')),
                          ]
                        ),
                        pw.Row(
                          children: [
                            pw.Container(width: 70, child: pw.Text('Durasi:', style: pw.TextStyle(color: PdfColors.grey700))),
                            pw.Expanded(child: pw.Text('${item['duration'] ?? '-'}')),
                          ]
                        ),
                        pw.Row(
                          children: [
                            pw.Container(width: 70, child: pw.Text('Cara Pakai:', style: pw.TextStyle(color: PdfColors.grey700))),
                            pw.Expanded(child: pw.Text('${item['method'] ?? '-'}')),
                          ]
                        ),
                      ]
                    )
                  );
                }
              ),
              
            pw.SizedBox(height: 20),
            
            // Catatan
            pw.Text('Catatan Dokter', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Text(notes),
            
            // Footer
            pw.Spacer(),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Dokumen ini dicetak otomatis dari Sistem Halopet',
                style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)
              )
            )
          ];
        }
      )
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resep_Halopet_${petName.replaceAll(' ', '_')}_$dateStr.pdf',
    );
  }
}

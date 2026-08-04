import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfPrescriptionGenerator {
  static Future<void> generateAndSharePrescription({
    required int consultationId,
    required String doctorName,
    required String petName,
    required List<dynamic> items,
    String? notes,
  }) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());
    
    // SIP Example since it's hardcoded in UI
    const sip = '1306/P/HK/0024';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('HALOPET KLINIK', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                        pw.Text('Layanan Telemedicine Terpadu', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Text('RESEP', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.blue),
                pw.SizedBox(height: 16),

                // Doctor & Patient Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(doctorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('SIP: $sip', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(dateStr, style: pw.TextStyle(fontSize: 10)),
                        pw.Text('ID: #$consultationId', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                
                pw.Row(
                  children: [
                    pw.Text('Pasien: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(petName),
                  ]
                ),
                pw.SizedBox(height: 24),
                
                // Prescription Symbol
                pw.Text('R/', style: pw.TextStyle(fontSize: 24, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),

                // Items
                if (items.isEmpty)
                  pw.Text('Tidak ada obat yang diresepkan.')
                else
                  ...items.map((item) {
                    final name = item['medicine_name'] ?? '';
                    final dose = item['dose'] ?? '';
                    final qty = item['qty'] ?? '';
                    
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 12, left: 16),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                                pw.Text(dose, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                              ]
                            ),
                          ),
                          pw.Text(qty, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]
                      ),
                    );
                  }).toList(),
                  
                pw.SizedBox(height: 24),

                // Notes
                if (notes != null && notes.isNotEmpty) ...[
                  pw.Text('Catatan:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text(notes, style: pw.TextStyle(fontSize: 10)),
                ],

                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.Center(
                  child: pw.Text(
                    'Resep ini berlaku 7 hari sejak tanggal diterbitkan.',
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Resep_${petName.replaceAll(' ', '_')}_$dateStr.pdf',
    );
  }
}

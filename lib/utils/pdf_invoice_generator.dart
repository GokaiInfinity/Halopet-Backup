import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfInvoiceGenerator {
  static Future<void> generateAndShareInvoice({
    required int consultationId,
    required String doctorName,
    required String method,
    required int fee,
    required int adminFee,
  }) async {
    final pdf = pw.Document();
    final total = fee + adminFee;
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('HALOPET', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.blue),
                pw.SizedBox(height: 24),

                // Details
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Dibayarkan Kepada:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.Text('Halopet Telemedicine'),
                        pw.Text('Klinik Hewan Terpadu'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Detail Transaksi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.Text('ID Konsultasi : #$consultationId'),
                        pw.Text('Tanggal : $dateStr'),
                        pw.Text('Status : LUNAS', style: pw.TextStyle(color: PdfColors.green)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Table Header
                pw.Container(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Deskripsi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Jumlah', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),

                // Table Items
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Konsultasi Dokter ($method)\n$doctorName'),
                          pw.Text('Rp $fee'),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Biaya Layanan Aplikasi'),
                          pw.Text('Rp $adminFee'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Divider(),

                // Total
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL PEMBAYARAN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Rp $total', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Text(
                    'Terima kasih telah mempercayakan kesehatan hewan kesayangan Anda pada Halopet.',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Share / Print the document
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Invoice_Halopet_$consultationId.pdf',
    );
  }
}

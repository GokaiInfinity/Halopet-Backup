import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class PdfAdminReportGenerator {
  static Future<void> generateAndShareReport({
    required Map<String, int> stats,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allConsultations = await DatabaseHelper.instance.getAllConsultations(
      startDate: startDate,
      endDate: endDate,
    );
    final finishedConsultations = allConsultations.where((c) {
      final status = c['status'] as String?;
      return status == 'finished' || status == 'completed' || status == 'selesai';
    }).toList();

    final pdf = pw.Document();

    final String dateString = (startDate != null && endDate != null)
        ? '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'
        : 'Hari Ini (${DateFormat('dd MMM yyyy').format(DateTime.now())})';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('HALOPET',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF0F2646),
                        )),
                    pw.Text('Klinik Hewan & Telemedicine',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Jl. Satwa Sehat No. 123, Jakarta',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('LAPORAN AKTIVITAS',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Periode: $dateString',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(
                        'No. Invoice: INV-${DateFormat('yyyyMMdd').format(DateTime.now())}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(
                        'Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),

            // Laporan Medis
            pw.Text('Ringkasan Medis',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Indikator',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                _buildTableRow('Jumlah Konsultasi', '${stats['konsultasi_hari_ini']}'),
                _buildTableRow('Jumlah Pasien Aktif', '${stats['jumlah_pasien']}'),
                _buildTableRow('Jumlah Dokter Aktif', '${stats['jumlah_dokter']}'),
              ],
            ),
            pw.SizedBox(height: 30),

            // Laporan Keuangan
            pw.Text('Ringkasan Keuangan & Transaksi',
                style: pw.TextStyle(
                    fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Indikator',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Total',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                _buildTableRow('Transaksi Belum Lunas', '${stats['transaksi_belum_lunas']}'),
                _buildTableRow(
                  'Estimasi Pendapatan',
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(stats['total_pendapatan'] ?? 0),
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            
            // Rincian Konsultasi Selesai
            if (finishedConsultations.isNotEmpty) ...[
              pw.Text('Rincian Konsultasi Selesai',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['Tgl', 'Pasien', 'Dokter', 'Biaya'],
                data: finishedConsultations.map((c) {
                  final dt = c['created_at'] != null ? DateTime.parse(c['created_at'].toString()) : null;
                  final dtStr = dt != null ? DateFormat('dd/MM HH:mm').format(dt) : '-';
                  return [
                    dtStr,
                    '${c['pet_name'] ?? '-'}',
                    '${c['doctor_name'] ?? '-'}',
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(c['consultation_fee'] ?? 0),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui,'),
                    pw.SizedBox(height: 50),
                    pw.Text('( Administrator )',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'Laporan_Halopet.pdf');
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
}

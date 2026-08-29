import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../database/database_helper.dart';

class AdminDetailedReportScreen extends StatefulWidget {
  const AdminDetailedReportScreen({super.key});

  @override
  State<AdminDetailedReportScreen> createState() => _AdminDetailedReportScreenState();
}

class _AdminDetailedReportScreenState extends State<AdminDetailedReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _reportData = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseHelper.instance.getDetailedConsultationReport(
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _reportData = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTime? pickedStart = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Mulai',
    );
    
    if (pickedStart != null) {
      final DateTime? pickedEnd = await showDatePicker(
        context: context,
        initialDate: _endDate != null && _endDate!.isAfter(pickedStart) ? _endDate! : pickedStart,
        firstDate: pickedStart,
        lastDate: DateTime(2030),
        helpText: 'Pilih Tanggal Akhir',
      );
      
      if (pickedEnd != null) {
        setState(() {
          _startDate = pickedStart;
          _endDate = pickedEnd;
        });
        _loadData();
      }
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final titleFont = pw.Font.helveticaBold();
    final bodyFont = pw.Font.helvetica();
    final bodyFontBold = pw.Font.helveticaBold();

    final String dateRangeText = _startDate != null && _endDate != null
        ? '${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_endDate!)}'
        : 'Semua Waktu';

    double totalRevenue = 0;
    for (var row in _reportData) {
      if (row['status'] == 'completed' || row['status'] == 'selesai' || row['status'] == 'finished') {
        totalRevenue += (row['fee'] as num?)?.toDouble() ?? 0;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HALOPET', style: pw.TextStyle(font: titleFont, fontSize: 24, color: PdfColors.blue800)),
                      pw.Text('Laporan Detail Konsultasi', style: pw.TextStyle(font: bodyFontBold, fontSize: 16)),
                      pw.Text('Periode: $dateRangeText', style: pw.TextStyle(font: bodyFont, fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}', style: pw.TextStyle(font: bodyFont, fontSize: 10, color: PdfColors.grey600)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            _buildPdfTable(bodyFont, bodyFontBold),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total Konsultasi: ${_reportData.length}', style: pw.TextStyle(font: bodyFontBold, fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('Total Pendapatan: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalRevenue)}', 
                    style: pw.TextStyle(font: titleFont, fontSize: 16, color: PdfColors.green700)),
                ]
              )
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Laporan_HaloPet_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildPdfTable(pw.Font font, pw.Font fontBold) {
    final headers = ['No.', 'Tanggal', 'Pasien / Pemilik', 'Dokter', 'Keluhan', 'Status', 'Biaya'];
    
    int index = 1;
    final data = _reportData.map((row) {
      final dateStr = row['date']?.toString() ?? '';
      String formattedDate = dateStr;
      try {
        if (dateStr.isNotEmpty) {
           formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateStr));
        }
      } catch(e) {}

      final fee = (row['fee'] as num?)?.toDouble() ?? 0;
      final status = row['status']?.toString() ?? '';

      return [
        (index++).toString(),
        formattedDate,
        '${row['pet_name']}\n(${row['owner_name']})',
        row['doctor_name']?.toString() ?? '-',
        row['diagnosis']?.toString() ?? '-',
        status,
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(fee),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellStyle: pw.TextStyle(font: font, fontSize: 9),
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerLeft,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(3),
        5: const pw.FixedColumnWidth(50),
        6: const pw.FixedColumnWidth(60),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detail Laporan', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Periode Laporan:', style: TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
                      const SizedBox(height: 4),
                      Text(
                        _startDate != null && _endDate != null
                            ? '${DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_endDate!)}'
                            : 'Semua Waktu',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2646), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Pilih Tanggal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF45A5C7),
                    side: const BorderSide(color: Color(0xFF45A5C7)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E5EC)),
          
          // Data Section
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _reportData.isEmpty
                    ? const Center(child: Text('Tidak ada data konsultasi pada periode ini', style: TextStyle(color: Color(0xFF7A93AA))))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF0F4F8)),
                            dataRowMaxHeight: double.infinity,
                            columns: const [
                              DataColumn(label: Text('No.', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Pasien (Pemilik)', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Dokter', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Keluhan', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Biaya', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _reportData.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final row = entry.value;
                              final dateStr = row['date']?.toString() ?? '';
                              String formattedDate = dateStr;
                              try {
                                if (dateStr.isNotEmpty) {
                                   formattedDate = DateFormat('dd/MM/yyyy\nHH:mm').format(DateTime.parse(dateStr));
                                }
                              } catch(e) {}
                              
                              final fee = (row['fee'] as num?)?.toDouble() ?? 0;
                              final status = row['status']?.toString() ?? '';
                              
                              Color statusColor = Colors.grey;
                              if (status == 'completed' || status == 'selesai' || status == 'finished') statusColor = Colors.green;
                              if (status == 'waiting' || status == 'waiting_payment') statusColor = Colors.orange;

                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(formattedDate, style: const TextStyle(fontSize: 12)),
                                  )),
                                  DataCell(Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(row['pet_name']?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(row['owner_name']?.toString() ?? '-', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  )),
                                  DataCell(Text(row['doctor_name']?.toString() ?? '-', style: const TextStyle(fontSize: 13))),
                                  DataCell(SizedBox(
                                    width: 150,
                                    child: Text(row['diagnosis']?.toString() ?? '-', style: const TextStyle(fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
                                  )),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                                  )),
                                  DataCell(Text(
                                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(fee),
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F2646)),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
        ),
        child: ElevatedButton.icon(
          onPressed: _reportData.isEmpty ? null : _generatePdf,
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text('Cetak Laporan PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF45A5C7),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

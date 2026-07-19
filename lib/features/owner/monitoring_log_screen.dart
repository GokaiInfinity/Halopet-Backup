import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';

class MonitoringLogScreen extends StatefulWidget {
  final Map<String, dynamic> args; // Consultation object
  const MonitoringLogScreen({super.key, required this.args});

  @override
  State<MonitoringLogScreen> createState() => _MonitoringLogScreenState();
}

class _MonitoringLogScreenState extends State<MonitoringLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appetiteController = TextEditingController();
  final _activityController = TextEditingController();
  final _conditionController = TextEditingController();
  final _symptomsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cid = widget.args['id'] as int;
      final provider = context.read<ConsultationProvider>();

      await provider.addMonitoringLog(cid, {
        'appetite': _appetiteController.text.trim(),
        'activity': _activityController.text.trim(),
        'condition': _conditionController.text.trim(),
        'symptoms': _symptomsController.text.trim(),
      });

      _appetiteController.clear();
      _activityController.clear();
      _conditionController.clear();
      _symptomsController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Log monitoring berhasil ditambahkan.')));
        setState(() {}); // Refresh list
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cid = widget.args['id'] as int? ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Monitoring Pasca-Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, Object?>>>(
                future:
                    context.read<ConsultationProvider>().getMonitoringLogs(cid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final logs = snapshot.data ?? [];

                  if (logs.isEmpty) {
                    return const Center(
                        child: Text('Belum ada log monitoring.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal: ${log['date']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF7A93AA))),
                          const SizedBox(height: 8),
                          if ((log['condition'] as String).isNotEmpty)
                            _buildLogItem(
                                'Kondisi Umum', log['condition'] as String),
                          if ((log['appetite'] as String).isNotEmpty)
                            _buildLogItem(
                                'Nafsu Makan', log['appetite'] as String),
                          if ((log['activity'] as String).isNotEmpty)
                            _buildLogItem(
                                'Aktivitas', log['activity'] as String),
                          if ((log['symptoms'] as String).isNotEmpty)
                            _buildLogItem(
                                'Gejala Lain', log['symptoms'] as String),
                        ],
                      );
                    },
                  );
                }),
          ),

          // Form Add
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Log Baru',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              'Nafsu Makan', _appetiteController)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              'Aktivitas', _activityController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField('Kondisi Umum', _conditionController),
                  const SizedBox(height: 12),
                  _buildTextField('Gejala Tambahan', _symptomsController,
                      required: false),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF45A5C7),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text('Simpan Log',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null
          : null,
    );
  }

  Widget _buildLogItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0F2646))),
          ),
          const Text(': ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
              child: Text(content,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF0F2646)))),
        ],
      ),
    );
  }
}

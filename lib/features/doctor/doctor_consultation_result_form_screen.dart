import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/consultation_provider.dart';

class DoctorConsultationResultFormScreen extends StatefulWidget {
  final Map<String, dynamic> args; // Needs consultation ID
  const DoctorConsultationResultFormScreen({super.key, required this.args});

  @override
  State<DoctorConsultationResultFormScreen> createState() =>
      _DoctorConsultationResultFormScreenState();
}

class _DoctorConsultationResultFormScreenState
    extends State<DoctorConsultationResultFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  final _warningController = TextEditingController();
  final _prescriptionNotesController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _weightController = TextEditingController();
  String? _controlDecision;
  bool _isControl = false;

  List<Map<String, TextEditingController>> _medicines = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isControl = widget.args['is_control'] == 1;
    _addMedicine(); // Start with one empty medicine row
  }

  void _addMedicine() {
    setState(() {
      _medicines.add({
        'name': TextEditingController(),
        'dose': TextEditingController(),
        'qty': TextEditingController(),
      });
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final cid = (widget.args['id'] ?? widget.args['consultation_id']) as int;
      final provider = context.read<ConsultationProvider>();

      // Save consultation result
      await provider.saveConsultationResult(cid, {
        'diagnosis': _diagnosisController.text.trim(),
        'advice': _adviceController.text.trim(),
        'warning_signs': _warningController.text.trim(),
        'control_decision': _controlDecision ?? '',
        'temperature': double.tryParse(_temperatureController.text) ?? 0.0,
        'heart_rate': int.tryParse(_heartRateController.text) ?? 0,
        'respiratory_rate': int.tryParse(_respiratoryRateController.text) ?? 0,
        'weight_at_visit': double.tryParse(_weightController.text) ?? 0.0,
      });

      // Save prescription if filled
      List<Map<String, dynamic>> medItems = [];
      for (var med in _medicines) {
        if (med['name']!.text.trim().isNotEmpty) {
          medItems.add({
            'medicine_name': med['name']!.text.trim(),
            'dose': med['dose']!.text.trim(),
            'qty': med['qty']!.text.trim(),
          });
        }
      }

      if (medItems.isNotEmpty ||
          _prescriptionNotesController.text.trim().isNotEmpty) {
        await provider.savePrescription(
            cid, _prescriptionNotesController.text.trim(), medItems);
      }

      // Update consultation status to finished
      await provider.updateStatus(cid, 'finished');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Hasil Konsultasi Berhasil Disimpan')));
        // Return to doctor home
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.doctorHome, (route) => false);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Input Hasil Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionTitle('Pemeriksaan Fisik & Tanda Vital'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Suhu Tubuh (°C)', _temperatureController, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('Berat Badan (kg)', _weightController, keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Detak Jantung (bpm)', _heartRateController, keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('Pernapasan (rpm)', _respiratoryRateController, keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Diagnosis & Saran'),
                  CheckboxListTile(
                    title: const Text('Tandai sebagai Konsultasi Kontrol', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Pilih jika ini adalah kunjungan lanjutan dari perawatan sebelumnya.'),
                    value: _isControl,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        _isControl = val ?? false;
                        if (!_isControl) _controlDecision = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isControl) ...[
                    DropdownButtonFormField<String>(
                      value: _controlDecision,
                      decoration: const InputDecoration(
                        labelText: 'Keputusan Kontrol',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Perawatan dihentikan',
                            child: Text('Perawatan dihentikan')),
                        DropdownMenuItem(
                            value: 'Perawatan dilanjutkan',
                            child: Text('Perawatan dilanjutkan')),
                        DropdownMenuItem(
                            value: 'Dosis obat disesuaikan',
                            child: Text('Dosis obat disesuaikan')),
                        DropdownMenuItem(
                            value: 'Obat diganti', child: Text('Obat diganti')),
                        DropdownMenuItem(
                            value: 'Hewan harus diperiksa langsung',
                            child: Text('Hewan harus diperiksa langsung')),
                      ],
                      onChanged: (val) =>
                          setState(() => _controlDecision = val),
                      validator: (val) =>
                          val == null ? 'Pilih keputusan kontrol' : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField('Diagnosis Sementara', _diagnosisController,
                      maxLines: 2),
                  const SizedBox(height: 16),
                  _buildTextField('Saran Perawatan', _adviceController,
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Tanda Bahaya (Warning Signs)', _warningController,
                      required: false, maxLines: 2),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Resep Elektronik'),
                  ..._medicines.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var med = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E5EC)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Obat ${idx + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              if (_medicines.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      setState(() => _medicines.removeAt(idx)),
                                )
                            ],
                          ),
                          _buildTextField('Nama Obat', med['name']!,
                              required: false),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                      'Dosis (cth: 2x1)', med['dose']!,
                                      required: false)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildTextField('Jml', med['qty']!,
                                      required: false)),
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                  TextButton.icon(
                    onPressed: _addMedicine,
                    icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
                    label: const Text('Tambah Obat',
                        style: TextStyle(color: Color(0xFF2196F3))),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Catatan Resep (Opsional)', _prescriptionNotesController,
                      required: false, maxLines: 2),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF45A5C7),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan & Selesaikan Konsultasi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2646))),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool required = true, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: required
          ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null
          : null,
    );
  }
}

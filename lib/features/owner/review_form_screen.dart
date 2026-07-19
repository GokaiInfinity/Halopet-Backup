import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../app/theme.dart';

class ReviewFormScreen extends StatefulWidget {
  final Map<String, dynamic> args; // consultation map
  const ReviewFormScreen({super.key, required this.args});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();

  double _ratingDoctor = 5;
  double _ratingInfo = 5;
  double _ratingApp = 5;
  double _ratingQuality = 5;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final cid = widget.args['id'] as int;
      final provider = context.read<ConsultationProvider>();

      await provider.submitReview(cid, {
        'rating_doctor': _ratingDoctor,
        'rating_info': _ratingInfo,
        'rating_app': _ratingApp,
        'rating_quality': _ratingQuality,
        'review_text': _reviewController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ulasan berhasil dikirim')));
        Navigator.pop(context); // Go back to consultation history
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRatingBar(
      String title, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFF0F2646))),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: Colors.amber,
          label: value.toInt().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Beri Ulasan',
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
                  const Text('Penilaian untuk Dokter',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 16),
                  _buildRatingBar('Kinerja Dokter', _ratingDoctor,
                      (val) => setState(() => _ratingDoctor = val)),
                  const SizedBox(height: 24),
                  const Text('Penilaian untuk Sistem',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 16),
                  _buildRatingBar('Informasi/Panduan di Aplikasi', _ratingInfo,
                      (val) => setState(() => _ratingInfo = val)),
                  _buildRatingBar('Kemudahan Penggunaan Aplikasi', _ratingApp,
                      (val) => setState(() => _ratingApp = val)),
                  _buildRatingBar('Kualitas Konsultasi', _ratingQuality,
                      (val) => setState(() => _ratingQuality = val)),
                  const SizedBox(height: 32),
                  const Text('Ulasan Tambahan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2646))),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Tuliskan pengalaman Anda...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2646),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kirim Ulasan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}

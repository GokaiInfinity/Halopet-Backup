import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../app/theme.dart';
import '../../core/widgets/common_widgets.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String _category = 'Teknis/Aplikasi';
  bool _isLoading = false;

  final List<String> _categories = [
    'Teknis/Aplikasi',
    'Masalah Pembayaran',
    'Masalah Konsultasi',
    'Akun & Privasi',
    'Lainnya'
  ];

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().user!;
      final provider = context.read<ConsultationProvider>();

      await provider.submitHelpTicket(
          user.id, _category, _descController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tiket bantuan berhasil dikirim!')));
        _descController.clear();
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
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Pusat Bantuan',
              style: TextStyle(color: Color(0xFF0F2646))),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kirim Pengaduan / Tiket Bantuan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2646))),
                const SizedBox(height: 16),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                              labelText: 'Kategori Kendala',
                              border: OutlineInputBorder()),
                          items: _categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsikan kendala Anda',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Deskripsi tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitTicket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2646),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Kirim Tiket',
                                  style: TextStyle(color: Colors.white)),
                        )
                      ],
                    )),
                const SizedBox(height: 32),
                const Text('Tiket Saya',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2646))),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, Object?>>>(
                  future: context
                      .read<ConsultationProvider>()
                      .getHelpTickets(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    final tickets = snapshot.data ?? [];

                    if (tickets.isEmpty) return const Text('Belum ada tiket.');

                    return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final t = tickets[i];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFE0E5EC)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(t['category'] as String,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: t['status'] == 'open'
                                                ? Colors.orange.shade100
                                                : Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Text(
                                            t['status'] == 'open'
                                                ? 'Terbuka'
                                                : 'Selesai',
                                            style: TextStyle(
                                                color: t['status'] == 'open'
                                                    ? Colors.orange.shade800
                                                    : Colors.green.shade800,
                                                fontSize: 10)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(t['description'] as String),
                                  if (t['admin_reply'] != null &&
                                      (t['admin_reply'] as String)
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF5F7FA),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Balasan Admin:',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Color(0xFF45A5C7))),
                                            const SizedBox(height: 4),
                                            Text(t['admin_reply'] as String,
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ))
                                  ]
                                ]),
                          );
                        });
                  },
                )
              ],
            )));
  }
}

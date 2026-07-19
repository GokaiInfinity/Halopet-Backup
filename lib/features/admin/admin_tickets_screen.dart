import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/role_scaffolds.dart';
import 'admin_screens.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({super.key});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  List<Map<String, Object?>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final tickets =
        await context.read<ConsultationProvider>().getAllHelpTickets();
    setState(() {
      _tickets = tickets;
      _isLoading = false;
    });
  }

  Future<void> _replyTicket(int ticketId) async {
    final TextEditingController replyController = TextEditingController();
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Tiket'),
        content: TextField(
          controller: replyController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Pesan balasan',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Kirim Balasan'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await context
          .read<ConsultationProvider>()
          .replyHelpTicket(ticketId, replyController.text.trim());
      _loadTickets();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balasan tiket berhasil dikirim')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Tiket Bantuan',
      index: 7, // Adjust this index as needed for your bottom navigation
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? const EmptyState(
                  title: 'Tidak ada tiket',
                  message: 'Belum ada tiket bantuan yang masuk.',
                  icon: Icons.support_agent)
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) {
                    final t = _tickets[i];
                    final bool isOpen = t['status'] == 'open';

                    return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(
                                          t['user_name'] as String? ?? 'User',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: isOpen
                                            ? Colors.orange.shade100
                                            : Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                        isOpen ? 'Menunggu Balasan' : 'Selesai',
                                        style: TextStyle(
                                            color: isOpen
                                                ? Colors.orange.shade800
                                                : Colors.green.shade800,
                                            fontSize: 10)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(t['category'] as String,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              const Divider(height: 24),
                              const Text('Deskripsi Kendala:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(t['description'] as String),
                              if (t['admin_reply'] != null &&
                                  (t['admin_reply'] as String).isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FA),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Balasan Anda:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color(0xFF45A5C7))),
                                        const SizedBox(height: 4),
                                        Text(t['admin_reply'] as String,
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ],
                                    ))
                              ],
                              if (isOpen) ...[
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _replyTicket(t['id'] as int),
                                    icon: const Icon(Icons.reply, size: 16),
                                    label: const Text('Balas Tiket'),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ));
                  }),
    );
  }
}

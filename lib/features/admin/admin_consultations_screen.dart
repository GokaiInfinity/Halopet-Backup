import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/widgets/role_scaffolds.dart';
import '../../providers/consultation_provider.dart';
import 'package:intl/intl.dart';

class AdminConsultationsScreen extends StatefulWidget {
  const AdminConsultationsScreen({super.key});

  @override
  State<AdminConsultationsScreen> createState() =>
      _AdminConsultationsScreenState();
}

class _AdminConsultationsScreenState extends State<AdminConsultationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Semua Konsultasi',
      index: 2, // Highlight Konsultasi tab
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          final items = provider.items;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada konsultasi yang tercatat di sistem.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final consultation = items[index];
              final petName = consultation['pet_name'] as String? ?? 'Hewan';
              final docName = consultation['doctor_name'] as String? ?? 'Dokter';
              final complaint = consultation['complaint'] as String? ?? '-';
              final status = consultation['status'] as String? ?? 'Menunggu';
              final rawDate = consultation['created_at'] as String?;

              String formattedDate = '';
              if (rawDate != null) {
                try {
                  final dt = DateTime.parse(rawDate);
                  formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dt);
                } catch (e) {
                  formattedDate = rawDate;
                }
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                  ),
                  title: Text(
                    '$petName & $docName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Keluhan: $complaint'),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigate to chat screen with the consultation data
                    // For admin, they can view the chat.
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: consultation,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'berlangsung':
      case 'aktif':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

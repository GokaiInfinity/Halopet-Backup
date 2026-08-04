import 'package:flutter/material.dart';

class AdminNotificationSettingsScreen extends StatefulWidget {
  const AdminNotificationSettingsScreen({super.key});

  @override
  State<AdminNotificationSettingsScreen> createState() => _AdminNotificationSettingsScreenState();
}

class _AdminNotificationSettingsScreenState extends State<AdminNotificationSettingsScreen> {
  bool _newRegistration = true;
  bool _newTransaction = true;
  bool _newTicket = true;
  bool _systemAlert = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2646)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan Notifikasi',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitchItem(
            title: 'Pengguna Baru',
            subtitle: 'Notifikasi pendaftaran dokter atau pemilik hewan baru',
            value: _newRegistration,
            onChanged: (val) => setState(() => _newRegistration = val),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            title: 'Transaksi Baru',
            subtitle: 'Notifikasi pembayaran baru yang masuk',
            value: _newTransaction,
            onChanged: (val) => setState(() => _newTransaction = val),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            title: 'Tiket Bantuan',
            subtitle: 'Notifikasi saat ada tiket bantuan baru dari pengguna',
            value: _newTicket,
            onChanged: (val) => setState(() => _newTicket = val),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            title: 'Peringatan Sistem',
            subtitle: 'Info mengenai peringatan dan pemeliharaan sistem',
            value: _systemAlert,
            onChanged: (val) => setState(() => _systemAlert = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F2646))),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF7A93AA))),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF45A5C7),
        ),
      ],
    );
  }
}

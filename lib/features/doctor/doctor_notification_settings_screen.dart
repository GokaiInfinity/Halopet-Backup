import 'package:flutter/material.dart';

class DoctorNotificationSettingsScreen extends StatefulWidget {
  const DoctorNotificationSettingsScreen({super.key});

  @override
  State<DoctorNotificationSettingsScreen> createState() => _DoctorNotificationSettingsScreenState();
}

class _DoctorNotificationSettingsScreenState extends State<DoctorNotificationSettingsScreen> {
  bool _consultationReminder = true;
  bool _newMessage = true;
  bool _systemUpdate = true;

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
            title: 'Pengingat Konsultasi',
            subtitle: 'Notifikasi saat jadwal konsultasi akan segera dimulai',
            value: _consultationReminder,
            onChanged: (val) => setState(() => _consultationReminder = val),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            title: 'Pesan Baru',
            subtitle: 'Notifikasi saat ada pesan baru dari pasien',
            value: _newMessage,
            onChanged: (val) => setState(() => _newMessage = val),
          ),
          const Divider(height: 24),
          _buildSwitchItem(
            title: 'Pembaruan Sistem',
            subtitle: 'Info mengenai pembaruan aplikasi dan pemeliharaan sistem',
            value: _systemUpdate,
            onChanged: (val) => setState(() => _systemUpdate = val),
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

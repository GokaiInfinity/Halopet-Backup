import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';

// ==== MOCKUP 31: RUANG KONSULTASI CHAT ====
class ConsultationRoomScreen extends StatefulWidget {
  final Map<String, dynamic> args; // Expects doctor name, specialty, etc.
  const ConsultationRoomScreen({super.key, required this.args});

  @override
  State<ConsultationRoomScreen> createState() => _ConsultationRoomScreenState();
}

class _ConsultationRoomScreenState extends State<ConsultationRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'doctor',
      'text': 'Selamat pagi, ada yang bisa saya bantu untuk hewan Anda?',
      'time': '09:30',
      'type': 'text'
    },
    {
      'sender': 'user',
      'text':
          'Pagi dok, dia sering garuk-garuk dan bulunya rontok di beberapa bagian.',
      'time': '09:31',
      'type': 'text'
    },
    {
      'sender': 'doctor',
      'text': 'Baik, boleh kirim foto bagian yang rontok?',
      'time': '09:31',
      'type': 'text'
    },
    {'sender': 'user', 'image': 'mock_image', 'time': '09:32', 'type': 'image'},
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': _msgController.text.trim(),
        'time': '09:35', // mocked time
        'type': 'text'
      });
      _msgController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _messages.add({
          'sender': 'user',
          'image': base64String,
          'time': '09:35',
          'type': 'image'
        });
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.args['doctor_name'] ?? 'Drh. Anisa Putri';
    final doctorSpec = widget.args['specialist'] ?? 'Kulit & Bulu';

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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE6F4F8),
              child:
                  const Icon(Icons.person, color: Color(0xFF45A5C7), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorName,
                    style: const TextStyle(
                        color: Color(0xFF0F2646),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(doctorSpec,
                    style: const TextStyle(
                        color: Color(0xFF7A93AA), fontSize: 11)),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Online',
                  style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF45A5C7)),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCall,
                arguments: widget.args),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF45A5C7)),
            onPressed: () {}, // Not implemented in mock
          ),
          TextButton(
            onPressed: () {
              final role = context.read<AuthProvider>().user?.role;
              if (role == 'doctor') {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.doctorConsultationResultForm,
                    arguments: widget.args);
              } else {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.consultationResult,
                    arguments: widget.args);
              }
            },
            child: const Text('Akhiri Sesi',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender'] == 'user';
                return _buildMessageBubble(msg, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
            color: isMe ? const Color(0xFFE3F2FD) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2)),
            ]),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['type'] == 'text')
              Text(msg['text'],
                  style: TextStyle(
                      color: isMe
                          ? const Color(0xFF0F2646)
                          : const Color(0xFF0F2646))),
            if (msg['type'] == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: msg['image'] == 'mock_image'
                    ? Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets,
                            color: Colors.grey, size: 40),
                      )
                    : Image.memory(base64Decode(msg['image']),
                        width: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg['time'],
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF7A93AA))),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all,
                      size: 14, color: Color(0xFF2196F3)),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E5EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.camera_alt,
                          color: Color(0xFF7A93AA)),
                      onPressed: () => _sendImage(ImageSource.camera)),
                  IconButton(
                      icon: const Icon(Icons.photo, color: Color(0xFF7A93AA)),
                      onPressed: () => _sendImage(ImageSource.gallery)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2196F3),
              radius: 24,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

// ==== MOCKUP 32: VIDEO CALL ====
class VideoCallScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const VideoCallScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Video Background (Doctor)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF2C3E50),
            child: const Center(
              child: Icon(Icons.person, size: 120, color: Colors.white30),
            ),
          ),
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Video Call',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('08:24',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),
          ),
          // PIP (User/Pet video)
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(child: Icon(Icons.pets, color: Colors.white)),
            ),
          ),
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCtrlBtn(Icons.mic, Colors.white24, Colors.white, () {}),
                _buildCtrlBtn(
                    Icons.videocam, Colors.white24, Colors.white, () {}),
                _buildCtrlBtn(Icons.call_end, Colors.red, Colors.white, () {
                  // Simulate finishing consultation
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.consultationFinished,
                      arguments: args);
                }, size: 64),
                _buildCtrlBtn(
                    Icons.switch_camera, Colors.white24, Colors.white, () {}),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCtrlBtn(
      IconData icon, Color bgColor, Color iconColor, VoidCallback onTap,
      {double size = 56}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}

// ==== MOCKUP 33: KONSULTASI SELESAI ====
class ConsultationFinishedScreen extends StatelessWidget {
  final Map<String, dynamic> args;
  const ConsultationFinishedScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final doctorName = args['doctor_name'] ?? 'Drh. Anisa Putri';
    final petName = args['pet_name'] ?? 'Hewan Anda';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0F2646)),
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text('Konsultasi Selesai',
            style: TextStyle(color: Color(0xFF0F2646))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFE3F2FD),
              child: const Icon(Icons.assignment_turned_in,
                  size: 60, color: Color(0xFF2196F3)),
            ),
            const SizedBox(height: 32),
            const Text('Konsultasi telah selesai',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 8),
            const Text('Terima kasih telah berkonsultasi\ndengan dokter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7A93AA))),
            const SizedBox(height: 48),

            // Info box
            _buildInfoRow(Icons.person, 'Dokter', doctorName),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.pets, 'Hewan', petName),
            const SizedBox(height: 16),
            _buildInfoRow(
                Icons.calendar_today, 'Tanggal', 'Hari ini - Selesai'),

            const Spacer(),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                  context, AppRoutes.consultationResult,
                  arguments: args),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lihat Hasil Konsultasi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Kembali ke Beranda',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFF0F4F8),
          child: Icon(icon, color: const Color(0xFF7A93AA), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A93AA))),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
          ],
        )
      ],
    );
  }
}

// ==== MOCKUP 8: PEMBAYARAN KONSULTASI ====
class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> args; // Needs consultationId, doctor, method
  const PaymentScreen({super.key, required this.args});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'Transfer Bank';

  void _processPayment() {
    // Simulasi memproses pembayaran
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.pop(context); // Tutup loading

      // Update status di provider/database (Simulasi)
      try {
        final cid = (widget.args['consultationId'] as num).toInt();
        if (context.mounted) {
          await context
              .read<ConsultationProvider>()
              .updateStatus(cid, 'scheduled');
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembayaran Berhasil!')));
        }
      } catch (e) {
        // ignore
      }

      // Ke riwayat konsultasi
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.ownerConsultations, (r) => r.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.args['doctor'] as Map<String, dynamic>? ?? {};
    final fee = (doctor['consultation_fee'] as num?)?.toInt() ?? 50000;
    final adminFee = 5000;
    final total = fee + adminFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pembayaran',
            style: TextStyle(color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Ringkasan Pemesanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildRow('Dokter', doctor['name']?.toString() ?? 'Drh.'),
                const Divider(height: 24),
                _buildRow(
                    'Metode', widget.args['method']?.toString() ?? 'Chat'),
                const Divider(height: 24),
                _buildRow('Biaya Konsultasi', 'Rp $fee'),
                const SizedBox(height: 8),
                _buildRow('Biaya Layanan', 'Rp $adminFee'),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Rp $total',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                            fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Metode Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildMethodOption('Transfer Bank', Icons.account_balance),
          _buildMethodOption('Virtual Account', Icons.credit_card),
          _buildMethodOption(
              'Dompet Digital (OVO, GoPay)', Icons.account_balance_wallet),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Bayar Sekarang',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7A93AA))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMethodOption(String title, IconData icon) {
    final isSelected = selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
              width: 2),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF7A93AA)),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF2196F3)),
          ],
        ),
      ),
    );
  }
}

// ==== MOCKUP 9: PERSIAPAN KONSULTASI ====
class ConsultationPrepScreen extends StatelessWidget {
  final Map<String, dynamic> args; // Needs consultation ID, doctor details etc
  const ConsultationPrepScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Persiapan Konsultasi',
            style: TextStyle(color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konsultasi Anda akan segera dimulai.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Sambil menunggu dokter bergabung, pastikan Anda menyiapkan hal-following:',
                style: TextStyle(color: Color(0xFF7A93AA))),
            const SizedBox(height: 32),
            _buildPrepItem(Icons.pets, 'Siapkan Hewan Anda',
                'Pastikan hewan berada di dekat Anda dan dalam kondisi tenang.'),
            const SizedBox(height: 24),
            _buildPrepItem(Icons.description, 'Siapkan Rekam Medis',
                'Siapkan buku vaksin atau hasil pemeriksaan sebelumnya jika ada.'),
            const SizedBox(height: 24),
            _buildPrepItem(Icons.wifi, 'Koneksi Internet',
                'Pastikan koneksi internet stabil untuk kelancaran konsultasi (terutama untuk Video Call).'),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Ke Ruang Konsultasi
                try {
                  final cid = (args['id'] as num?)?.toInt();
                  if (cid != null) {
                    await context
                        .read<ConsultationProvider>()
                        .updateStatus(cid, 'in_progress');
                  }
                } catch (_) {}

                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.consultationRoom,
                      arguments: args);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50), // Green for go
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Saya Sudah Siap, Masuk Ruang',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrepItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFFE6F4F8),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF45A5C7)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
              const SizedBox(height: 4),
              Text(desc,
                  style:
                      const TextStyle(color: Color(0xFF7A93AA), fontSize: 13)),
            ],
          ),
        )
      ],
    );
  }
}

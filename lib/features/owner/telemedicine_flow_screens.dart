import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../database/database_helper.dart';
import 'screens/chat_screen.dart' as chat_screen;
import '../../utils/pdf_invoice_generator.dart' as pdf_gen;

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
  List<Map<String, dynamic>> _messages = [];
  Timer? _timer;

  int get consultationId => widget.args['consultation_id'] ?? widget.args['id'] ?? 1;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final userId = context.read<AuthProvider>().user?.id ?? 1;
    await DatabaseHelper.instance.markMessagesAsRead(consultationId, userId);
    final msgs = await DatabaseHelper.instance.getMessages(consultationId);
    if (mounted) {
      final wasAtBottom = _scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50;
      
      setState(() {
        _messages = msgs;
      });

      if (wasAtBottom) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final text = _msgController.text.trim();
    _msgController.clear();
    
    final userId = context.read<AuthProvider>().user?.id ?? 1;
    await DatabaseHelper.instance.addMessage(consultationId, userId, text);
    await _loadMessages();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final userId = context.read<AuthProvider>().user?.id ?? 1;
      await DatabaseHelper.instance.addMessage(consultationId, userId, '[IMAGE]:$base64String');
      await _loadMessages();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showQuestionnaire() async {
    final details = await DatabaseHelper.instance.getConsultationDetails(consultationId);
    final complaint = details['complaint'] as Map<String, dynamic>?;
    final screening = details['screening'] as Map<String, dynamic>?;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    const Text('Hasil Kuesioner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
                    const SizedBox(height: 16),
                    if (complaint == null && screening == null)
                      const Text('Tidak ada data kuesioner.')
                    else ...[
                      if (complaint != null)
                        Builder(
                          builder: (context) {
                            final mainComplaintsStr = complaint['main_complaints']?.toString() ?? '';
                            Map<String, dynamic>? parsedComplaints;
                            if (mainComplaintsStr.trim().startsWith('{')) {
                              try {
                                parsedComplaints = jsonDecode(mainComplaintsStr);
                              } catch (_) {}
                            }
                            
                            Widget buildField(String label, dynamic value, {bool isBool = false}) {
                              if (value == null || value.toString().isEmpty || value.toString() == 'null' || value.toString() == '-') return const SizedBox.shrink();
                              String displayValue = value.toString();
                              if (isBool && value is int) {
                                if (value == 0) return const SizedBox.shrink();
                                displayValue = value == 1 ? 'Ya' : 'Tidak';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                    Text(displayValue),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildField('Layanan', complaint['service_type']),
                                if (parsedComplaints != null) ...[
                                  const Text('Gejala Utama', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                  const SizedBox(height: 4),
                                  ...parsedComplaints.entries.map((e) {
                                    final keyStr = e.key.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                                    final valStr = e.value == true ? 'Ya' : e.value == false ? 'Tidak' : e.value.toString();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 2, child: Text(keyStr, style: const TextStyle(color: Colors.grey))),
                                          Expanded(flex: 3, child: Text(valStr, style: const TextStyle(fontWeight: FontWeight.w500))),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const SizedBox(height: 8),
                                ] else 
                                  buildField('Gejala Utama', complaint['main_complaints']),
                                buildField('Durasi', complaint['duration']),
                                buildField('Nafsu Makan', complaint['appetite']),
                                buildField('Aktivitas', complaint['activity']),
                                buildField('Urin', complaint['urine']),
                                buildField('Feses', complaint['feces']),
                                buildField('Muntah', complaint['vomit'], isBool: true),
                                buildField('Pernapasan', complaint['respiratory']),
                                buildField('Kulit & Bulu', complaint['skin_coat']),
                                buildField('Obat-obatan', complaint['medication']),
                                const Divider(height: 24),
                              ],
                            );
                          }
                        ),
                      if (screening != null) ...[
                        const Text('Hasil Skrining Darurat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(height: 8),
                        Text('Kategori: ${screening['result_category']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Kesulitan Bernapas: ${screening['difficulty_breathing'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Kejang: ${screening['seizures'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Tidak Sadar: ${screening['unconscious'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Pendarahan Hebat: ${screening['heavy_bleeding'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Trauma Parah: ${screening['severe_trauma'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Tidak Bisa Berdiri: ${screening['cannot_stand'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Keracunan: ${screening['poisoning'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Tidak Bisa Kencing: ${screening['cannot_urinate'] == 1 ? 'Ya' : 'Tidak'}'),
                        Text('Muntah Terus-menerus: ${screening['continuous_vomiting'] == 1 ? 'Ya' : 'Tidak'}'),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTitle = widget.args['chat_title'] ?? widget.args['doctor_name'] ?? 'Dokter';
    final chatSubtitle = widget.args['chat_subtitle'] ?? widget.args['specialist'] ?? 'Kulit & Bulu';

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
                Text(chatTitle,
                    style: const TextStyle(
                        color: Color(0xFF0F2646),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(chatSubtitle,
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
          if (context.read<AuthProvider>().user?.role == 'doctor') ...[
            IconButton(
              icon: const Icon(Icons.edit_note, color: Color(0xFF45A5C7)),
              tooltip: 'Isi Hasil Konsultasi (Rekam Medis)',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorConsultationResultForm, arguments: widget.args),
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF45A5C7)),
              tooltip: 'Riwayat Medis',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorMedicalHistory, arguments: widget.args),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.assignment, color: Color(0xFF45A5C7)),
            tooltip: 'Kuesioner Pemilik',
            onPressed: _showQuestionnaire,
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF45A5C7)),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCall,
                arguments: widget.args),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF45A5C7)),
            onPressed: () {}, // Not implemented in mock
          ),
          if (context.read<AuthProvider>().user?.role == 'doctor')
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.doctorConsultationResultForm,
                    arguments: widget.args);
              },
              child: const Text('Akhiri Sesi',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Only leave the room
              },
              child: const Text('Keluar Ruangan',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + ((_messages.isNotEmpty && _messages.last['sender_id'] == context.read<AuthProvider>().user?.id) ? 1 : 0),
              itemBuilder: (context, index) {
                final showWaiting = _messages.isNotEmpty && _messages.last['sender_id'] == context.read<AuthProvider>().user?.id;
                if (showWaiting && index == _messages.length) {
                  return const chat_screen.WaitingIndicator();
                }
                final msg = _messages[index];
                final senderId = msg['sender_id'] as int;
                final isMe = senderId == context.read<AuthProvider>().user?.id;
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
    final text = msg['message'] as String;
    final isImage = text.startsWith('[IMAGE]:');
    final content = isImage ? text.substring(8) : text;
    
    // Parse time
    final createdAt = msg['created_at'] as String;
    final time = "${DateTime.parse(createdAt).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(createdAt).toLocal().minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isMe ? () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hapus Pesan?'),
              content: const Text('Pesan ini akan ditarik (unsend) secara permanen.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await DatabaseHelper.instance.deleteMessage(msg['id'] as int);
                    _loadMessages();
                  }, 
                  child: const Text('Tarik Pesan', style: TextStyle(color: Colors.red))
                ),
              ],
            ),
          );
        } : null,
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
            if (!isImage)
              Text(content,
                  style: TextStyle(
                      color: isMe
                          ? const Color(0xFF0F2646)
                          : const Color(0xFF0F2646))),
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: content == 'mock_image'
                    ? Container(
                        height: 120,
                        width: 120,
                        color: const Color(0xFFE0E0E0),
                        child: const Icon(Icons.pets,
                            size: 40, color: Colors.grey),
                      )
                    : Image.memory(
                        base64Decode(content),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time,
                    style:
                        const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, color: (msg['is_read'] as int? ?? 0) == 1 ? Colors.blue : Colors.grey, size: 12),
                ]
              ],
            )
          ],
        ),
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
    final doctorName = args['doctor_name'] ?? 'Dokter';
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

  Future<void> _processPayment() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    bool isDialogShowing = true;

    try {
      final cid = (widget.args['consultationId'] as num).toInt();
      final doctor = widget.args['doctor'] as Map<String, dynamic>;
      final fee = (doctor['consultation_fee'] as num?)?.toInt() ?? 50000;
      final adminFee = 5000;
      final total = fee + adminFee;
      
      // Hit Node.js backend
      String baseUrl = 'http://localhost:3000';
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        baseUrl = 'http://10.0.2.2:3000';
      }
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': 'HALOPET-$cid-${DateTime.now().millisecondsSinceEpoch}',
          'gross_amount': total,
          'customer_details': {
            'first_name': context.read<AuthProvider>().user?.name ?? 'Guest',
            'email': context.read<AuthProvider>().user?.email ?? 'guest@example.com'
          }
        })
      );

      if (context.mounted && isDialogShowing) {
        Navigator.pop(context); 
        isDialogShowing = false;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final redirectUrl = data['redirect_url'];
          final uri = Uri.parse(redirectUrl);
          
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            
            // Tampilkan dialog konfirmasi pembayaran simulasi setelah browser ditutup/kembali ke app
            if (context.mounted) {
              _showSimulationDialog(cid);
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka halaman pembayaran')));
            }
          }
        } else {
          throw Exception(data['message'] ?? 'Gagal mendapatkan token');
        }
      } else {
         throw Exception('Gagal menghubungi server');
      }

    } catch (e) {
      if (context.mounted && isDialogShowing) {
        Navigator.pop(context); 
        isDialogShowing = false;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _showSimulationDialog(int cid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Simulasi Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2646))),
        content: const Text('Apakah Anda sudah menyelesaikan pembayaran di halaman Midtrans?\n\n(Karena ini menggunakan SQLite lokal, Anda harus mengkonfirmasi secara manual untuk melanjutkan)'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Belum', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog simulasi
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                if (context.mounted) {
                  await context.read<ConsultationProvider>().updateStatus(cid, 'scheduled');
                }
              } catch (e) {
                // ignore
              }
              
              if (context.mounted) {
                Navigator.pop(context); // Tutup loading
                Navigator.pushReplacementNamed(context, AppRoutes.paymentSuccess, arguments: widget.args);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sudah, Lanjut!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

// ==== PAYMENT SUCCESS SCREEN ====
class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> args; // Needs consultationId, doctor, method, total, date
  const PaymentSuccessScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final doctor = args['doctor'] as Map<String, dynamic>? ?? {};
    final fee = (doctor['consultation_fee'] as num?)?.toInt() ?? 50000;
    final adminFee = 5000;
    final total = fee + adminFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil', style: TextStyle(color: Color(0xFF0F2646))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F2646)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Pembayaran Anda Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rp $total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export Invoice PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  await pdf_gen.PdfInvoiceGenerator.generateAndShareInvoice(
                    consultationId: (args['consultationId'] as num).toInt(),
                    doctorName: doctor['name']?.toString() ?? 'Drh.',
                    method: args['method']?.toString() ?? 'Chat',
                    fee: fee,
                    adminFee: adminFee,
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                child: const Text('Lihat Konsultasi'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.ownerConsultations, (r) => r.isFirst);
                },
              )
            ],
          ),
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

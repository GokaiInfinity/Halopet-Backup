import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/role_scaffolds.dart';
import '../../../database/database_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/consultation_provider.dart';
import '../../../providers/doctor_provider.dart';
import '../../../providers/pet_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.consultation});
  final Map<String, Object?> consultation;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, Object?>> messages = [];
  final text = TextEditingController();
  Timer? _timer;
  int _tick = 0;

  bool get _isExpired {
    final status = widget.consultation['status']?.toString().toLowerCase();
    if (status == 'finished' || status == 'selesai') return true;
    if (messages.isEmpty) return false;
    final start = DateTime.tryParse(messages.first['created_at']?.toString() ?? '') ?? DateTime.now();
    final expiry = start.add(const Duration(minutes: 10));
    return DateTime.now().isAfter(expiry);
  }

  String get _remainingTime {
    if (messages.isEmpty) return '10:00';
    final start = DateTime.tryParse(messages.first['created_at']?.toString() ?? '') ?? DateTime.now();
    final expiry = start.add(const Duration(minutes: 10));
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return '00:00';
    final m = diff.inMinutes.toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick++;
      if (_tick % 2 == 0) {
        load();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    text.dispose();
    super.dispose();
  }

  Future<void> load() async {
    final cid = widget.consultation['id'] as int? ?? widget.consultation['consultation_id'] as int? ?? 0;
    final newMessages = await DatabaseHelper.instance.getMessages(cid);
    if (mounted) {
      if (messages.length != newMessages.length) {
        setState(() {
          messages = newMessages;
        });
      }
    }
  }

  Future<void> send() async {
    if (text.text.trim().isEmpty) return;
    final cid = widget.consultation['id'] as int? ?? widget.consultation['consultation_id'] as int? ?? 0;
    await DatabaseHelper.instance.addMessage(
        cid,
        context.read<AuthProvider>().user!.id, text.text.trim());
    text.clear();
    await load();
  }

  Future<void> sendImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      await DatabaseHelper.instance.addMessage(widget.consultation['id'] as int,
          context.read<AuthProvider>().user!.id, '[IMAGE]$base64String');
      await load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthProvider>().user!.id;
    return Scaffold(
        appBar: AppBar(
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${widget.consultation['doctor_name'] ?? 'Konsultasi'}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          Text('${widget.consultation['pet_name'] ?? ''}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted))
        ]),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isExpired ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isExpired ? Colors.red.shade200 : Colors.blue.shade200)
                ),
                child: Text(
                  _isExpired ? 'Waktu Habis' : _remainingTime,
                  style: TextStyle(
                    color: _isExpired ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  )
                )
              )
            )
          ]
        ),
        body: Column(children: [
          Expanded(
              child: messages.isEmpty
                  ? const EmptyState(
                      title: 'Belum ada pesan',
                      message: 'Kirim pesan pertama kepada dokter.',
                      icon: Icons.forum_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + ((messages.isNotEmpty && messages.last['sender_id'] == me && widget.consultation['status'] != 'finished' && widget.consultation['status'] != 'selesai') ? 1 : 0),
                      itemBuilder: (_, i) {
                        final showWaiting = messages.isNotEmpty && messages.last['sender_id'] == me && widget.consultation['status'] != 'finished' && widget.consultation['status'] != 'selesai';
                        if (showWaiting && i == messages.length) {
                          return const WaitingIndicator();
                        }
                        final m = messages[i];
                        final mine = m['sender_id'] == me;
                        final msgText = m['message'].toString();
                        final isImage = msgText.startsWith('[IMAGE]');
                        return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                                onLongPress: mine ? () {
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
                                            await DatabaseHelper.instance.deleteMessage(m['id'] as int);
                                            await load();
                                          }, 
                                          child: const Text('Tarik Pesan', style: TextStyle(color: Colors.red))
                                        ),
                                      ],
                                    ),
                                  );
                                } : null,
                                child: Container(
                                    margin: const EdgeInsets.only(bottom: 9),
                                    padding: isImage
                                        ? EdgeInsets.zero
                                        : const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 11),
                                    constraints:
                                        const BoxConstraints(maxWidth: 290),
                                    decoration: BoxDecoration(
                                        color: isImage
                                            ? Colors.transparent
                                            : (mine
                                                ? AppColors.primary
                                                : Colors.white),
                                        borderRadius: BorderRadius.circular(16)),
                                    child: isImage
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.memory(
                                              base64Decode(msgText.substring(7)),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Text(msgText,
                                            style: TextStyle(
                                                color: mine
                                                    ? Colors.white
                                                    : AppColors.text)))));
                      })),
          SafeArea(
              top: false,
              child: _isExpired 
                ? Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const Text('Sesi konsultasi telah berakhir.', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold))
                  )
                : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    IconButton(
                        onPressed: () => sendImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt,
                            color: AppColors.muted)),
                    IconButton(
                        onPressed: () => sendImage(ImageSource.gallery),
                        icon: const Icon(Icons.image, color: AppColors.muted)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: TextField(
                            controller: text,
                            decoration: const InputDecoration(
                                hintText: 'Tulis pesan...', isDense: true))),
                    const SizedBox(width: 8),
                    IconButton.filled(
                        onPressed: send, icon: const Icon(Icons.send))
                  ])))
        ]));
  }
}

class WaitingIndicator extends StatefulWidget {
  const WaitingIndicator({super.key});
  @override
  State<WaitingIndicator> createState() => _WaitingIndicatorState();
}

class _WaitingIndicatorState extends State<WaitingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: (math.sin((_controller.value * 2 * math.pi) - (index * math.pi / 3)) + 1) / 2 * 0.7 + 0.3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

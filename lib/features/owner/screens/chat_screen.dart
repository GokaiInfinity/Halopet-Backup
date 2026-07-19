import 'dart:convert';
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
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    messages = await DatabaseHelper.instance
        .getMessages(widget.consultation['id'] as int);
    if (mounted) setState(() {});
  }

  Future<void> send() async {
    if (text.text.trim().isEmpty) return;
    await DatabaseHelper.instance.addMessage(widget.consultation['id'] as int,
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
        ])),
        body: Column(children: [
          Expanded(
              child: messages.isEmpty
                  ? const EmptyState(
                      title: 'Belum ada pesan',
                      message: 'Kirim pesan pertama kepada dokter.',
                      icon: Icons.forum_outlined)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final m = messages[i];
                        final mine = m['sender_id'] == me;
                        final msgText = m['message'].toString();
                        final isImage = msgText.startsWith('[IMAGE]');
                        return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
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
                                                : AppColors.text))));
                      })),
          SafeArea(
              top: false,
              child: Padding(
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

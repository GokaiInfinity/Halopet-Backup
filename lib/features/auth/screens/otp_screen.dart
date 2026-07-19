import '../auth_utils.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.email});
  final String email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF0F2646), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Verifikasi OTP',
            style: TextStyle(
                color: Color(0xFF0F2646),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3EBF8)),
              child: const Icon(Icons.email_outlined,
                  color: Color(0xFF45A5C7), size: 40),
            ),
            const SizedBox(height: 32),
            const Text('Masukkan kode verifikasi',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F2646))),
            const SizedBox(height: 12),
            Text(
              'Kode 6 digit telah dikirim ke\nemail ${widget.email.isEmpty ? 'Anda' : widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF7A93AA), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty
                            ? const Color(0xFF45A5C7)
                            : const Color(0xFFE0E5EC),
                        width: _focusNodes[index].hasFocus || _controllers[index].text.isNotEmpty ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) {
                      setState(() {});
                      _onChanged(value, index);
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2646)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _secondsRemaining > 0
                  ? 'Kirim ulang kode dalam 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                  : 'Kirim ulang kode sekarang',
              style: TextStyle(
                  color: _secondsRemaining > 0 ? const Color(0xFF7A93AA) : const Color(0xFF45A5C7),
                  fontSize: 12,
                  fontWeight: _secondsRemaining > 0 ? FontWeight.normal : FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.authSuccess),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF45A5C7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Verifikasi',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                const Text('Email salah?',
                    style: TextStyle(color: Color(0xFF7A93AA), fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ubah email',
                      style: TextStyle(
                          color: Color(0xFF45A5C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FC),
                border: Border.all(color: const Color(0xFFC0E0F6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF45A5C7)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Jangan bagikan kode OTP kepada siapa pun, termasuk pihak yang mengaku dari HaloPet.',
                      style: TextStyle(
                          color: Color(0xFF0F2646), fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

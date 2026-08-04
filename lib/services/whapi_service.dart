import 'dart:convert';
import 'package:http/http.dart' as http;

class WhapiService {
  static const String _apiToken = 'VC8kcmMJCVrhyIV2T9QvCCQWFcVR0v5B';

  static Future<bool> sendOtpWhatsApp(String phoneNumber, String otpCode) async {
    String formattedPhone = phoneNumber;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }

    final url = Uri.parse('https://gate.whapi.cloud/messages/text');

    final headers = {
      'Authorization': 'Bearer $_apiToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String pesanOtp = "Kode Verifikasi (OTP) HaloPet Anda adalah *$otpCode*.\n\nJANGAN berikan kode ini kepada siapa pun. Kode ini berlaku selama 5 menit.";

    final body = jsonEncode({
      "to": "$formattedPhone@s.whatsapp.net",
      "body": pesanOtp
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Gagal kirim OTP Whapi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Whapi API: $e');
      return false;
    }
  }
}

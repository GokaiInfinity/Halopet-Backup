import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseStorageService {
  static Future<String?> uploadImage(File file, {String bucket = 'halopet-storage'}) async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_KEY'];

    if (supabaseUrl == null || supabaseKey == null || supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      print('Error: SUPABASE_URL or SUPABASE_KEY not found in .env');
      return null;
    }

    final ext = file.path.split('.').last.toLowerCase();
    String contentType = 'image/jpeg';
    if (ext == 'png') contentType = 'image/png';
    if (ext == 'webp') contentType = 'image/webp';

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    
    // REST API Endpoint to upload file
    final uri = Uri.parse('$supabaseUrl/storage/v1/object/$bucket/$fileName');

    try {
      final request = http.Request('POST', uri)
        ..headers['Authorization'] = 'Bearer $supabaseKey'
        ..headers['Content-Type'] = contentType
        ..bodyBytes = await file.readAsBytes();

      final response = await http.Client().send(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return public URL
        return '$supabaseUrl/storage/v1/object/public/$bucket/$fileName';
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Upload failed: ${response.statusCode} $responseBody');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }
}

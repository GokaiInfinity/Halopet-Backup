import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  static Future<String?> uploadImage(File file, {String bucket = 'halopet-storage'}) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      final supabase = Supabase.instance.client;
      
      // Menggunakan SDK bawaan Supabase
      // Ini akan secara otomatis mengirimkan Token Sesi pengguna yang sedang login
      // Sehingga mematuhi Storage Policies (RLS) 'authenticated'
      await supabase.storage.from(bucket).upload(
        fileName, 
        file,
      );

      return supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String url, {String bucket = 'halopet-storage'}) async {
    try {
      if (url.isEmpty || !url.contains(bucket)) return false;
      
      // Mengambil nama file dari URL
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final fileName = pathSegments.last;
      
      final supabase = Supabase.instance.client;
      await supabase.storage.from(bucket).remove([fileName]);
      
      return true;
    } catch (e) {
      print('Exception during delete: $e');
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? user;
  bool loading = false;
  String? error;

  void clearError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id == null) return;
    user = AppUser(
        id: id,
        name: prefs.getString('name') ?? '',
        email: prefs.getString('email') ?? '',
        phone: prefs.getString('phone') ?? '',
        role: prefs.getString('role') ?? 'owner',
        photo: prefs.getString('photo') ?? '');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final row = await DatabaseHelper.instance.login(email, password);
      if (row == null) {
        error = 'Email atau password tidak sesuai.';
        return false;
      }
      user = AppUser.fromMap(row);
      await _saveSession(user!);
      return true;
    } catch (e) {
      error = 'Login gagal: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password,
      required String phone}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await DatabaseHelper.instance.registerOwner(
          name: name, email: email, password: password, phone: phone);
      return login(email, password);
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Exception: ')) {
        error = msg.split('Exception: ').last;
      } else if (msg.contains('UNIQUE')) {
        error = 'Email sudah terdaftar.';
      } else {
        error = 'Registrasi gagal: $msg';
      }
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    await (await SharedPreferences.getInstance()).clear();
    notifyListeners();
  }

  Future<void> _saveSession(AppUser value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', value.id);
    await prefs.setString('name', value.name);
    await prefs.setString('email', value.email);
    await prefs.setString('phone', value.phone);
    await prefs.setString('role', value.role);
    await prefs.setString('photo', value.photo);
  }

  Future<bool> updateProfile(String name, String phone, String photo) async {
    if (user == null) return false;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await DatabaseHelper.instance.updateUserProfile(user!.id, name, phone, photo);
      user = AppUser(
          id: user!.id,
          name: name,
          email: user!.email,
          phone: phone,
          role: user!.role,
          photo: photo);
      await _saveSession(user!);
      return true;
    } catch (e) {
      error = 'Gagal memperbarui profil: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

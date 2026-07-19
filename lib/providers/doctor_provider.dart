import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class DoctorProvider extends ChangeNotifier {
  List<Map<String, Object?>> doctors = [];
  bool loading = false;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      doctors = await DatabaseHelper.instance.getDoctors();
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }
}

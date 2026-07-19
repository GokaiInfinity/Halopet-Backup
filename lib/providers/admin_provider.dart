import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class AdminProvider extends ChangeNotifier {
  Map<String, int> stats = {};
  bool loading = false;
  Future<void> loadStats() async {
    loading = true;
    notifyListeners();
    stats = await DatabaseHelper.instance.getAdminStats();
    loading = false;
    notifyListeners();
  }
}

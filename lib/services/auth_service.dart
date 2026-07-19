import '../database/database_helper.dart';

class AuthService {
  Future<Map<String, Object?>?> login(String email, String password) =>
      DatabaseHelper.instance.login(email, password);
}

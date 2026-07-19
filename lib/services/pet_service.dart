import '../database/database_helper.dart';

class PetService {
  Future<List<Map<String, Object?>>> list(int ownerId) =>
      DatabaseHelper.instance.getPets(ownerId);
}

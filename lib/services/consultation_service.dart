import '../database/database_helper.dart';

class ConsultationService {
  Future<List<Map<String, Object?>>> ownerHistory(int ownerId) =>
      DatabaseHelper.instance.getOwnerConsultations(ownerId);
}

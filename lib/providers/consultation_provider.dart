import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class ConsultationProvider extends ChangeNotifier {
  List<Map<String, Object?>> items = [];
  bool loading = false;
  String? error;

  Future<void> loadOwner(int ownerId) async {
    loading = true;
    notifyListeners();
    try {
      items = await DatabaseHelper.instance.getOwnerConsultations(ownerId);
      error = null;
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadDoctor(int doctorId) async {
    loading = true;
    notifyListeners();
    try {
      items = await DatabaseHelper.instance.getDoctorConsultations(doctorId);
      error = null;
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<int> create(
          {required int petId,
          required int doctorId,
          required int scheduleId,
          required String complaint,
          String method = 'Chat'}) async =>
      DatabaseHelper.instance.createConsultation(
          petId: petId,
          doctorId: doctorId,
          scheduleId: scheduleId,
          complaint: complaint,
          method: method);

  Future<int> createWithDetails({
    required int petId,
    required int doctorId,
    required int scheduleId,
    required String complaint,
    required String method,
    required Map<String, Object?> complaintData,
    required Map<String, Object?> screeningData,
  }) async {
    return DatabaseHelper.instance.createConsultationWithDetails(
      petId: petId,
      doctorId: doctorId,
      scheduleId: scheduleId,
      complaint: complaint,
      method: method,
      complaintData: complaintData,
      screeningData: screeningData,
    );
  }

  Future<void> setStatus(int id, String status) async {
    await DatabaseHelper.instance.updateConsultationStatus(id, status);
    notifyListeners();
  }

  Future<void> updateStatus(int id, String status) async {
    await DatabaseHelper.instance.updateConsultationStatus(id, status);
    notifyListeners();
  }

  // ==== Phase 11-14 Post-Consultation Methods ====

  Future<int> saveConsultationResult(
      int consultationId, Map<String, dynamic> data) async {
    return DatabaseHelper.instance.saveConsultationResult(consultationId, data);
  }

  Future<Map<String, Object?>?> getConsultationResult(
      int consultationId) async {
    return DatabaseHelper.instance.getConsultationResult(consultationId);
  }

  Future<int> savePrescription(int consultationId, String notes,
      List<Map<String, dynamic>> items) async {
    return DatabaseHelper.instance
        .savePrescription(consultationId, notes, items);
  }

  Future<Map<String, dynamic>?> getPrescription(int consultationId) async {
    return DatabaseHelper.instance.getPrescription(consultationId);
  }

  Future<int> createMedicineOrder(int consultationId, String address,
      double medPrice, double delFee) async {
    return DatabaseHelper.instance
        .createMedicineOrder(consultationId, address, medPrice, delFee);
  }

  Future<Map<String, Object?>?> getMedicineOrder(int consultationId) async {
    return DatabaseHelper.instance.getMedicineOrder(consultationId);
  }

  Future<int> addMonitoringLog(
      int consultationId, Map<String, dynamic> data) async {
    return DatabaseHelper.instance.addMonitoringLog(consultationId, data);
  }

  Future<List<Map<String, Object?>>> getMonitoringLogs(
      int consultationId) async {
    return DatabaseHelper.instance.getMonitoringLogs(consultationId);
  }

  // ==== Phase 15-18 Methods ====

  Future<int> createControlConsultation(
      {required int petId,
      required int doctorId,
      required int scheduleId,
      required String complaint,
      required String method,
      required Map<String, Object?> complaintData,
      required Map<String, Object?> screeningData,
      required int parentConsultationId}) async {
    return DatabaseHelper.instance.createConsultationWithDetails(
        petId: petId,
        doctorId: doctorId,
        scheduleId: scheduleId,
        complaint: complaint,
        method: method,
        complaintData: complaintData,
        screeningData: screeningData,
        isControl: 1,
        parentConsultationId: parentConsultationId);
  }

  Future<int> submitReview(
      int consultationId, Map<String, dynamic> data) async {
    return DatabaseHelper.instance.submitReview(consultationId, data);
  }

  Future<Map<String, Object?>?> getReview(int consultationId) async {
    return DatabaseHelper.instance.getReview(consultationId);
  }

  Future<int> submitHelpTicket(
      int userId, String category, String description) async {
    return DatabaseHelper.instance
        .submitHelpTicket(userId, category, description);
  }

  Future<List<Map<String, Object?>>> getHelpTickets(int userId) async {
    return DatabaseHelper.instance.getHelpTickets(userId);
  }

  Future<List<Map<String, Object?>>> getAllHelpTickets() async {
    return DatabaseHelper.instance.getAllHelpTickets();
  }

  Future<void> replyHelpTicket(int ticketId, String reply) async {
    await DatabaseHelper.instance.replyHelpTicket(ticketId, reply);
  }
}

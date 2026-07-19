import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';

class PetProvider extends ChangeNotifier {
  List<Map<String, Object?>> pets = [];
  List<Map<String, Object?>> vaccinations = [];
  List<Map<String, Object?>> diseases = [];
  bool loading = false;
  bool loadingDetails = false;
  String? error;

  Future<void> load(int ownerId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      pets = await DatabaseHelper.instance.getPets(ownerId);
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<int?> save(Map<String, Object?> data, {int? id}) async {
    try {
      int savedId;
      if (id == null) {
        savedId = await DatabaseHelper.instance.addPet(data);
      } else {
        await DatabaseHelper.instance.updatePet(id, data);
        savedId = id;
      }
      await load(data['owner_id'] as int);
      return savedId;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return null;
    }
  }

  Future<void> remove(int id, int ownerId) async {
    await DatabaseHelper.instance.deletePet(id);
    await load(ownerId);
  }

  Future<void> loadDetails(int petId) async {
    loadingDetails = true;
    error = null;
    notifyListeners();
    try {
      vaccinations = await DatabaseHelper.instance.getVaccinations(petId);
      diseases = await DatabaseHelper.instance.getDiseases(petId);
    } catch (e) {
      error = '$e';
    }
    loadingDetails = false;
    notifyListeners();
  }

  Future<bool> saveVaccination(Map<String, Object?> data) async {
    try {
      await DatabaseHelper.instance.addVaccination(data);
      await loadDetails(data['pet_id'] as int);
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<void> removeVaccination(int id, int petId) async {
    await DatabaseHelper.instance.deleteVaccination(id);
    await loadDetails(petId);
  }

  Future<bool> saveDisease(Map<String, Object?> data) async {
    try {
      await DatabaseHelper.instance.addDisease(data);
      await loadDetails(data['pet_id'] as int);
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }

  Future<void> removeDisease(int id, int petId) async {
    await DatabaseHelper.instance.deleteDisease(id);
    await loadDetails(petId);
  }
}

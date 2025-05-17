import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'medication_model.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  final SharedPreferences _prefs;

  MedicationProvider(this._prefs) {
    _loadMedications();
  }

  List<Medication> get medications => _medications;

  Future<void> _loadMedications() async {
    final String? medsJson = _prefs.getString('medications');
    if (medsJson != null) {
      final List<dynamic> decoded = json.decode(medsJson);
      _medications = decoded.map((item) => Medication.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveMedications() async {
    final String encoded = json.encode(_medications.map((m) => m.toJson()).toList());
    await _prefs.setString('medications', encoded);
  }

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    await _saveMedications();
    notifyListeners();
  }

  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    await _saveMedications();
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      await _saveMedications();
      notifyListeners();
    }
  }
} 
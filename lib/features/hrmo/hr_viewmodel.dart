import 'package:flutter/foundation.dart';

import 'hr_service.dart';
import 'personnel_model.dart';

class HRViewModel extends ChangeNotifier {
  final HRService service;

  HRViewModel({required this.service});

  List<Personnel> _personnel = <Personnel>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Personnel> get personnel => _personnel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _setLoading(true);
    _setError(null);
    try {
      final List<Personnel> items = await service.fetchAll();
      _personnel = items;
    } catch (e) {
      _setError('Failed to load personnel');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addPersonnel({
    required String firstName,
    required String lastName,
    required String position,
  }) async {
    _setError(null);
    try {
      final Personnel created = await service.add(
        PersonnelCreate(firstName: firstName, lastName: lastName, position: position),
      );
      _personnel = List<Personnel>.from(_personnel)..add(created);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add personnel');
      notifyListeners();
    }
  }

  Future<void> removePersonnel(String id) async {
    _setError(null);
    try {
      await service.remove(id);
      _personnel = _personnel.where((Personnel p) => p.id != id).toList(growable: false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove personnel');
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }
}



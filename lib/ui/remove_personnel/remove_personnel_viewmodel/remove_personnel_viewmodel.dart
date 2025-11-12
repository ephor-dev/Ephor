import 'package:flutter/foundation.dart';

import 'package:ephor/domain/models/personnel/personnel.dart';
import 'package:ephor/data/services/personnel_service.dart';

/// ViewModel for managing personnel list and removal operations
class RemovePersonnelViewModel extends ChangeNotifier {
  final PersonnelService service;

  RemovePersonnelViewModel({required this.service});

  List<PersonnelModel> _personnel = <PersonnelModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  String? _removingId; // Track which personnel is being removed

  List<PersonnelModel> get personnel => _personnel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool isRemoving(String id) => _removingId == id;

  /// Load all personnel from the service
  Future<void> load() async {
    _setLoading(true);
    _setError(null);
    try {
      final List<PersonnelModel> items = await service.fetchAll();
      _personnel = items;
    } catch (e) {
      _setError('Failed to load personnel: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Remove a personnel by ID
  Future<bool> removePersonnel(String id) async {
    _setError(null);
    _removingId = id;
    notifyListeners();

    try {
      await service.remove(id);
      _personnel = _personnel.where((PersonnelModel p) => p.id != id).toList(growable: false);
      _removingId = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove personnel: ${e.toString()}');
      _removingId = null;
      notifyListeners();
      return false;
    }
  }

  /// Refresh the personnel list
  Future<void> refresh() async {
    await load();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }
}

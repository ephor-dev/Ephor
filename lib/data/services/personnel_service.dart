import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:ephor/domain/models/personnel/personnel.dart';

/// Service interface for personnel data operations
abstract interface class PersonnelService {
  Future<List<PersonnelModel>> fetchAll();
  Future<PersonnelModel> add(PersonnelModel personnel);
  Future<void> remove(String id);
  Future<PersonnelModel?> getById(String id);
}

/// In-memory implementation of PersonnelService
/// This will be replaced with actual Supabase/Firebase service later
class PersonnelInMemoryService implements PersonnelService {
  final List<PersonnelModel> _items = <PersonnelModel>[];

  PersonnelInMemoryService({List<PersonnelModel>? seed}) {
    if (seed != null) {
      _items.addAll(seed);
    }
  }

  /// Get all personnel (for inspection/debugging)
  /// This allows you to see the data in code
  List<PersonnelModel> getAllPersonnel() {
    return List<PersonnelModel>.unmodifiable(_items);
  }

  /// Get the count of personnel
  int get count => _items.length;

  /// Print all personnel to console (for debugging)
  void printAllPersonnel() {
    debugPrint('=== All Saved Personnel (${_items.length} total) ===');
    if (_items.isEmpty) {
      debugPrint('No personnel saved yet.');
    } else {
      for (int i = 0; i < _items.length; i++) {
        final PersonnelModel p = _items[i];
        debugPrint('[$i] ${p.fullName}');
        debugPrint('    ID: ${p.id}');
        debugPrint('    Type: ${p.employeeType.name}');
        debugPrint('    Department: ${p.department ?? 'None'}');
        debugPrint('    Tags: ${p.extraTags.join(', ')}');
        debugPrint('    Created: ${p.createdAt}');
        debugPrint('    JSON: ${p.toJson()}');
        debugPrint('');
      }
    }
    debugPrint('==========================================');
  }

  @override
  Future<List<PersonnelModel>> fetchAll() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<PersonnelModel>.unmodifiable(_items);
  }

  @override
  Future<PersonnelModel> add(PersonnelModel personnel) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _items.add(personnel);
    
    // Debug print to see the data
    debugPrint('=== Personnel Added ===');
    debugPrint('ID: ${personnel.id}');
    debugPrint('Name: ${personnel.fullName}');
    debugPrint('Type: ${personnel.employeeType.name}');
    debugPrint('Department: ${personnel.department ?? 'None'}');
    debugPrint('Tags: ${personnel.extraTags.join(', ')}');
    debugPrint('Total Personnel: ${_items.length}');
    debugPrint('JSON: ${personnel.toJson()}');
    debugPrint('======================');
    
    return personnel;
  }

  @override
  Future<void> remove(String id) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _items.removeWhere((PersonnelModel p) => p.id == id);
    
    // Debug print
    debugPrint('Personnel removed: $id');
    debugPrint('Remaining personnel count: ${_items.length}');
  }

  @override
  Future<PersonnelModel?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      return _items.firstWhere((PersonnelModel p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Shared service instance for the entire app
/// Both AddPersonnelView and RemovePersonnelView use this instance
/// In production, this would be provided via dependency injection
final PersonnelInMemoryService sharedPersonnelService = PersonnelInMemoryService();


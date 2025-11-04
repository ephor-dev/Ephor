import 'dart:async';

import 'package:flutter/foundation.dart';

import 'personnel_model.dart';

abstract interface class HRService {
  Future<List<Personnel>> fetchAll();
  Future<Personnel> add(PersonnelCreate input);
  Future<void> remove(String id);
}

class HRInMemoryService implements HRService {
  final List<Personnel> _items;
  int _idCounter = 0;

  HRInMemoryService({List<Personnel>? seed}) : _items = List<Personnel>.from(seed ?? <Personnel>[]);

  @override
  Future<List<Personnel>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<Personnel>.unmodifiable(_items);
  }

  @override
  Future<Personnel> add(PersonnelCreate input) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final String id = (++_idCounter).toString();
    final Personnel created = Personnel(
      id: id,
      firstName: input.firstName.trim(),
      lastName: input.lastName.trim(),
      position: input.position.trim(),
      createdAt: DateTime.now(),
    );
    _items.add(created);
    return created;
  }

  @override
  Future<void> remove(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _items.removeWhere((Personnel p) => p.id == id);
  }
}



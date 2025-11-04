import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'personnel_model.dart';

class AddPersonnelViewModel extends ChangeNotifier {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  final List<String> departments = <String>[
    'EE Department',
    'IT Department',
    'CS Department',
    'HR Department',
  ];

  EmployeeType employeeType = EmployeeType.personnel;
  String? selectedDepartment = 'EE Department';
  bool noDepartment = false;

  ThemeMode themeMode = ThemeMode.light;

  void toggleThemeMode() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setEmployeeType(EmployeeType type) {
    employeeType = type;
    notifyListeners();
  }

  void setNoDepartment(bool value) {
    noDepartment = value;
    if (noDepartment) selectedDepartment = null;
    notifyListeners();
  }

  void setDepartment(String? value) {
    selectedDepartment = value;
    notifyListeners();
  }

  PersonnelModel? confirm() {
    final String last = lastNameController.text.trim();
    final String first = firstNameController.text.trim();
    if (last.isEmpty || first.isEmpty) {
      return null;
    }
    final List<String> tagList = tagsController.text
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList(growable: false);
    return PersonnelModel(
      id: UniqueKey().toString(),
      lastName: last,
      firstName: first,
      middleName: middleNameController.text.trim().isEmpty ? null : middleNameController.text.trim(),
      employeeType: employeeType,
      department: noDepartment ? null : selectedDepartment,
      extraTags: tagList,
      createdAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    tagsController.dispose();
    super.dispose();
  }
}



import 'package:ephor/domain/models/form_editor/section_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class FormModel {
  final String id;
  final String title;
  final String description;
  final List<SectionModel> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FormModel({
    String? id,
    required this.title,
    required this.description,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
  }) : id = id ?? '';


  FormModel copyWith({
    String? id,
    String? title,
    String? description,
    List<SectionModel>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FormModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'sections': sections.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    // Only include 'id' if it's set and not empty
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    
    return map;
  }

  factory FormModel.fromJson(Map<String, dynamic> json) {
    final sectionsList = json['sections'] as List? ?? [];
    final sections = sectionsList
        .map((s) => SectionModel.fromJson(s as Map<String, dynamic>))
        .toList();
    
    return FormModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sections: sections,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}


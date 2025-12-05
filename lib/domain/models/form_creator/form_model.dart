// domain/models/form/form_model.dart

import 'package:ephor/domain/models/form_creator/form_enums.dart';
import 'package:ephor/domain/models/form_creator/section_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class FormModel {
  final String id;
  final String title;
  final String description;
  final FormStatus status;
  final List<SectionModel> sections;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final int responseCount;

  const FormModel({
    String? id,
    required this.title,
    required this.description,
    required this.status,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.responseCount = 0,
  }) : id = id ?? '';

  // Business logic methods
  bool get isPublished => status == FormStatus.published;
  bool get isDraft => status == FormStatus.draft;
  bool get hasResponses => responseCount > 0;
  bool get canBePublished => _validateForPublish();

  bool _validateForPublish() {
    if (title.trim().isEmpty) return false;
    if (sections.isEmpty) return false;
    
    // At least one section must have questions
    return sections.any((section) => section.questions.isNotEmpty);
  }

  FormModel copyWith({
    String? id,
    String? title,
    String? description,
    FormStatus? status,
    List<SectionModel>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    int? responseCount,
  }) {
    return FormModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      responseCount: responseCount ?? this.responseCount,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'status': status.toJson(),
      'sections': sections.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'response_count': responseCount,
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
      status: FormStatus.fromJson(json['status'] as String? ?? 'draft'),
      sections: sections,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      createdBy: json['created_by'] as String? ?? '',
      responseCount: json['response_count'] as int? ?? 0,
    );
  }
}


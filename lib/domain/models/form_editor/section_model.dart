import 'package:ephor/domain/models/form_editor/question_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class SectionModel {
  final String id;
  final String title;
  final String description;
  final List<QuestionModel> questions;
  final int orderIndex;

  const SectionModel({
    String? id,
    required this.title,
    required this.description,
    required this.questions,
    required this.orderIndex,
  }) : id = id ?? '';

  SectionModel copyWith({
    String? id,
    String? title,
    String? description,
    List<QuestionModel>? questions,
    int? orderIndex,
  }) {
    return SectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'order_index': orderIndex,
    };
    
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    
    return map;
  }

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] as List? ?? [];
    final questions = questionsList
        .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();
    
    return SectionModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      questions: questions,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}
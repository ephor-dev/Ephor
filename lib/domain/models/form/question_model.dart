// domain/models/form/question_model.dart

import 'package:ephor/domain/models/form/form_enums.dart';
import 'package:flutter/foundation.dart';

@immutable
class QuestionModel {
  final String id;
  final String questionText;
  final QuestionType type;
  final bool isRequired;
  final List<String>? options;
  final int orderIndex;
  final Map<String, dynamic>? config;

  const QuestionModel({
    String? id,
    required this.questionText,
    required this.type,
    required this.isRequired,
    this.options,
    required this.orderIndex,
    this.config,
  }) : id = id ?? '';

  QuestionModel copyWith({
    String? id,
    String? questionText,
    QuestionType? type,
    bool? isRequired,
    List<String>? options,
    int? orderIndex,
    Map<String, dynamic>? config,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      orderIndex: orderIndex ?? this.orderIndex,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'question_text': questionText,
      'type': type.toJson(),
      'is_required': isRequired,
      'order_index': orderIndex,
    };
    
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    
    if (options != null) {
      map['options'] = options;
    }
    
    if (config != null) {
      map['config'] = config;
    }
    
    return map;
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String?,
      questionText: json['question_text'] as String? ?? '',
      type: QuestionType.fromJson(json['type'] as String? ?? 'text'),
      isRequired: json['is_required'] as bool? ?? false,
      options: json['options'] != null 
          ? List<String>.from(json['options'] as List)
          : null,
      orderIndex: json['order_index'] as int? ?? 0,
      config: json['config'] as Map<String, dynamic>?,
    );
  }
}


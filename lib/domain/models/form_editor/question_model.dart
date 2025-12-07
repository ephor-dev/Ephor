// domain/models/form/question_model.dart

import 'dart:convert'; // Required for jsonDecode
import 'package:ephor/domain/models/form_editor/form_enums.dart';
import 'package:flutter/foundation.dart';

@immutable
class QuestionModel {
  final String id;
  final String questionText;
  final QuestionType type;
  final bool isRequired;
  // CHANGED: From List<String> to List<Map> to support {label: "Yes", value: 1}
  final List<Map<String, dynamic>>? options; 
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
    List<Map<String, dynamic>>? options, // Updated type here
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
    
    // Helper to safely parse Options (Handles String vs List crash)
    List<Map<String, dynamic>>? parseOptions(dynamic value) {
      if (value == null) return null;
      
      // If Supabase returns a JSON String: "[{...}]"
      if (value is String) {
        if (value.isEmpty) return [];
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<Map<String, dynamic>>.from(decoded);
          }
        } catch (_) {
          return []; 
        }
      }
      
      // If Supabase returns a direct List: [{...}]
      if (value is List) {
        return List<Map<String, dynamic>>.from(
          value.map((e) => e as Map<String, dynamic>)
        );
      }
      return [];
    }

    // Helper to safely parse Config (Handles String vs Map crash)
    Map<String, dynamic>? parseConfig(dynamic value) {
      if (value == null) return null;
      
      if (value is String) {
        if (value.isEmpty) return {};
        try {
          return Map<String, dynamic>.from(jsonDecode(value));
        } catch (_) {
          return {};
        }
      }
      
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    }

    return QuestionModel(
      id: json['id'] as String?,
      questionText: json['question_text'] as String? ?? '',
      type: QuestionType.fromJson(json['type'] as String? ?? 'text'),
      isRequired: json['is_required'] as bool? ?? false,
      
      // Use the helper to parse options
      options: parseOptions(json['options']),
      
      orderIndex: json['order_index'] as int? ?? 0,
      
      // Use the helper to parse config
      config: parseConfig(json['config']),
    );
  }
}
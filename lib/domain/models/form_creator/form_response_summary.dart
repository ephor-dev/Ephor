// domain/models/form/form_response_summary.dart

import 'package:flutter/foundation.dart';

@immutable
class FormResponseSummary {
  final String formId;
  final int totalResponses;
  final DateTime? lastResponseAt;
  final Map<String, int> responsesByDate;

  const FormResponseSummary({
    required this.formId,
    required this.totalResponses,
    this.lastResponseAt,
    required this.responsesByDate,
  });

  factory FormResponseSummary.fromJson(Map<String, dynamic> json) {
    final responsesMap = json['responses_by_date'] as Map<String, dynamic>? ?? {};
    final responsesByDate = responsesMap.map(
      (key, value) => MapEntry(key, value as int),
    );

    return FormResponseSummary(
      formId: json['form_id'] as String,
      totalResponses: json['total_responses'] as int? ?? 0,
      lastResponseAt: json['last_response_at'] != null
          ? DateTime.parse(json['last_response_at'] as String)
          : null,
      responsesByDate: responsesByDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'total_responses': totalResponses,
      'last_response_at': lastResponseAt?.toIso8601String(),
      'responses_by_date': responsesByDate,
    };
  }
}


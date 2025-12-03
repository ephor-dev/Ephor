// domain/models/catna/catna_assessment.dart

import 'package:flutter/foundation.dart';

/// Domain model for CATNA (Competency Assessment and Training Needs Analysis) data.
///
/// This model represents the structure of data collected across Forms 1, 2, and 3.
/// It's used to validate and structure the JSON payload before sending to Supabase.
@immutable
class CatnaAssessmentModel {
  final String? employeeCode;
  final CatnaIdentifyingData? identifyingData;
  final CatnaCompetencyRatings? competencyRatings;
  final CatnaTrainingNeeds? trainingNeeds;
  final CatnaQuarterPlans? quarterPlans;

  const CatnaAssessmentModel({
    this.employeeCode,
    this.identifyingData,
    this.competencyRatings,
    this.trainingNeeds,
    this.quarterPlans,
  });

  /// Converts the model to a JSON map suitable for Supabase insertion.
  Map<String, dynamic> toJson() {
    return {
      if (employeeCode != null) 'employee_code': employeeCode,
      if (identifyingData != null) 'identifying_data': identifyingData!.toJson(),
      if (competencyRatings != null) 'competency_ratings': competencyRatings!.toJson(),
      if (trainingNeeds != null) 'training_needs': trainingNeeds!.toJson(),
      if (quarterPlans != null) 'quarter_plans': quarterPlans!.toJson(),
    };
  }
}

/// Form 1: Identifying Data
@immutable
class CatnaIdentifyingData {
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? designation;
  final String? office;
  final String? operatingUnit;
  final int? yearsInCurrentPosition;
  final String? reviewStartDate; // ISO date string (yyyy-MM-dd)
  final String? reviewEndDate; // ISO date string (yyyy-MM-dd)
  final String? assessmentDate; // ISO date string (yyyy-MM-dd)
  final String? purposeOfAssessment;

  const CatnaIdentifyingData({
    this.firstName,
    this.lastName,
    this.middleName,
    this.designation,
    this.office,
    this.operatingUnit,
    this.yearsInCurrentPosition,
    this.reviewStartDate,
    this.reviewEndDate,
    this.assessmentDate,
    this.purposeOfAssessment,
  });

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (designation != null) 'designation': designation,
      if (office != null) 'office': office,
      if (operatingUnit != null) 'operating_unit': operatingUnit,
      if (yearsInCurrentPosition != null) 'years_in_current_position': yearsInCurrentPosition,
      if (reviewStartDate != null) 'review_start_date': reviewStartDate,
      if (reviewEndDate != null) 'review_end_date': reviewEndDate,
      if (assessmentDate != null) 'assessment_date': assessmentDate,
      if (purposeOfAssessment != null) 'purpose_of_assessment': purposeOfAssessment,
    };
  }

  factory CatnaIdentifyingData.fromJson(Map<String, dynamic> json) {
    return CatnaIdentifyingData(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      designation: json['designation'] as String?,
      office: json['office'] as String?,
      operatingUnit: json['operating_unit'] as String?,
      yearsInCurrentPosition: json['years_in_current_position'] as int?,
      reviewStartDate: json['review_start_date'] as String?,
      reviewEndDate: json['review_end_date'] as String?,
      assessmentDate: json['assessment_date'] as String?,
      purposeOfAssessment: json['purpose_of_assessment'] as String?,
    );
  }
}

/// Form 2: Competency Ratings
@immutable
class CatnaCompetencyRatings {
  final Map<String, int> knowledge; // item text -> rating (1-4)
  final Map<String, int> skills;
  final Map<String, int> attitudes;
  final CatnaAverages? averages;

  const CatnaCompetencyRatings({
    required this.knowledge,
    required this.skills,
    required this.attitudes,
    this.averages,
  });

  Map<String, dynamic> toJson() {
    return {
      'knowledge': knowledge,
      'skills': skills,
      'attitudes': attitudes,
      if (averages != null) 'averages': averages!.toJson(),
    };
  }

  factory CatnaCompetencyRatings.fromJson(Map<String, dynamic> json) {
    return CatnaCompetencyRatings(
      knowledge: Map<String, int>.from(json['knowledge'] as Map),
      skills: Map<String, int>.from(json['skills'] as Map),
      attitudes: Map<String, int>.from(json['attitudes'] as Map),
      averages: json['averages'] != null
          ? CatnaAverages.fromJson(json['averages'] as Map<String, dynamic>)
          : null,
    );
  }
}

@immutable
class CatnaAverages {
  final double knowledge;
  final double skills;
  final double attitude;
  final double? overall;

  const CatnaAverages({
    required this.knowledge,
    required this.skills,
    required this.attitude,
    this.overall,
  });

  Map<String, dynamic> toJson() {
    return {
      'knowledge': knowledge,
      'skills': skills,
      'attitude': attitude,
      if (overall != null) 'overall': overall,
    };
  }

  factory CatnaAverages.fromJson(Map<String, dynamic> json) {
    return CatnaAverages(
      knowledge: (json['knowledge'] as num).toDouble(),
      skills: (json['skills'] as num).toDouble(),
      attitude: (json['attitude'] as num).toDouble(),
      overall: json['overall'] != null ? (json['overall'] as num).toDouble() : null,
    );
  }
}

/// Form 3: Training Needs
@immutable
class CatnaTrainingNeeds {
  final List<String> knowledge;
  final List<String> skills;
  final List<String> attitudes;

  const CatnaTrainingNeeds({
    required this.knowledge,
    required this.skills,
    required this.attitudes,
  });

  Map<String, dynamic> toJson() {
    return {
      'knowledge': knowledge,
      'skills': skills,
      'attitudes': attitudes,
    };
  }

  factory CatnaTrainingNeeds.fromJson(Map<String, dynamic> json) {
    return CatnaTrainingNeeds(
      knowledge: List<String>.from(json['knowledge'] as List),
      skills: List<String>.from(json['skills'] as List),
      attitudes: List<String>.from(json['attitudes'] as List),
    );
  }
}

/// Form 3: Quarter Plans (Q1-Q4)
@immutable
class CatnaQuarterPlans {
  final CatnaQuarterPlan? q1;
  final CatnaQuarterPlan? q2;
  final CatnaQuarterPlan? q3;
  final CatnaQuarterPlan? q4;

  const CatnaQuarterPlans({
    this.q1,
    this.q2,
    this.q3,
    this.q4,
  });

  Map<String, dynamic> toJson() {
    return {
      if (q1 != null) 'q1': q1!.toJson(),
      if (q2 != null) 'q2': q2!.toJson(),
      if (q3 != null) 'q3': q3!.toJson(),
      if (q4 != null) 'q4': q4!.toJson(),
    };
  }

  factory CatnaQuarterPlans.fromJson(Map<String, dynamic> json) {
    return CatnaQuarterPlans(
      q1: json['q1'] != null ? CatnaQuarterPlan.fromJson(json['q1'] as Map<String, dynamic>) : null,
      q2: json['q2'] != null ? CatnaQuarterPlan.fromJson(json['q2'] as Map<String, dynamic>) : null,
      q3: json['q3'] != null ? CatnaQuarterPlan.fromJson(json['q3'] as Map<String, dynamic>) : null,
      q4: json['q4'] != null ? CatnaQuarterPlan.fromJson(json['q4'] as Map<String, dynamic>) : null,
    );
  }
}

@immutable
class CatnaQuarterPlan {
  final String? title;
  final CatnaCategories categories;

  const CatnaQuarterPlan({
    this.title,
    required this.categories,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      'categories': categories.toJson(),
    };
  }

  factory CatnaQuarterPlan.fromJson(Map<String, dynamic> json) {
    return CatnaQuarterPlan(
      title: json['title'] as String?,
      categories: CatnaCategories.fromJson(json['categories'] as Map<String, dynamic>),
    );
  }
}

@immutable
class CatnaCategories {
  final bool mandatory;
  final bool knowledgeBased;
  final bool skillBased;
  final bool attitudinalBased;

  const CatnaCategories({
    required this.mandatory,
    required this.knowledgeBased,
    required this.skillBased,
    required this.attitudinalBased,
  });

  Map<String, dynamic> toJson() {
    return {
      'mandatory': mandatory,
      'knowledge_based': knowledgeBased,
      'skill_based': skillBased,
      'attitudinal_based': attitudinalBased,
    };
  }

  factory CatnaCategories.fromJson(Map<String, dynamic> json) {
    return CatnaCategories(
      mandatory: json['mandatory'] as bool? ?? false,
      knowledgeBased: json['knowledge_based'] as bool? ?? false,
      skillBased: json['skill_based'] as bool? ?? false,
      attitudinalBased: json['attitudinal_based'] as bool? ?? false,
    );
  }
}


import 'package:flutter/foundation.dart';

@immutable
class CatnaAssessmentModel {
  final String? employeeCode;
  final CatnaIdentifyingData? identifyingData;
  final CatnaCompetencyRatings? competencyRatings;

  const CatnaAssessmentModel({
    this.employeeCode,
    this.identifyingData,
    this.competencyRatings,
  });

  /// Converts the model to a JSON map suitable for Supabase insertion.
  Map<String, dynamic> toJson() {
    return {
      if (employeeCode != null) 'employee_code': employeeCode,
      if (identifyingData != null) 'identifying_data': identifyingData!.toJson(),
      if (competencyRatings != null) 'competency_ratings': competencyRatings!.toJson(),
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
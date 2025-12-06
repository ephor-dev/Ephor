// domain/models/form/form_enums.dart

/// Status of a form
enum FormStatus {
  draft,
  published,
  archived;

  String toJson() => name;

  static FormStatus fromJson(String json) {
    return FormStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => FormStatus.draft,
    );
  }
}

/// Type of question in a form
enum QuestionType {
  text,
  multipleChoice,
  checkbox,
  ratingScale,
  date,
  fileUpload;

  String toJson() => name;

  static QuestionType fromJson(String json) {
    return QuestionType.values.firstWhere(
      (e) => e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => QuestionType.text,
    );
  }
}


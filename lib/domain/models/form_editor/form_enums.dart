enum QuestionType {
  text,
  multipleChoice,
  checkbox,
  ratingScale,
  date,
  dropdown,
  number,
  fileUpload;

  String toJson() => name;

  static QuestionType fromJson(String json) {
    return QuestionType.values.firstWhere(
      (e) => e.name.toLowerCase() == json.toLowerCase(),
      orElse: () => QuestionType.text,
    );
  }
}
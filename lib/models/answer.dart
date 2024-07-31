class QuestionnaireQuestion {
  final int questionID;
  final bool answer;

  QuestionnaireQuestion({
    required this.questionID,
    required this.answer,
  });

  factory QuestionnaireQuestion.fromJson(Map<String, dynamic> json) {
    return QuestionnaireQuestion(
      questionID: json['questionID'] as int? ?? 0,
      answer: json['answer'] as bool? ?? false,
    );
  }
}

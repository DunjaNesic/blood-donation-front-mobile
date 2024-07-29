class Question {
  final int questionID;
  final String? questionText;
  final int flag;

  Question({
    required this.questionID,
    this.questionText,
    required this.flag,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionID: json['questionID'] as int,
      questionText: json['questionText'] as String?,
      flag: json['flag'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionID': questionID,
      'questionText': questionText,
      'flag': flag,
    };
  }

  @override
  String toString() {
    return questionText ?? "";
  }
}

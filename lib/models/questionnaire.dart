import 'package:blood_donation/models/answer.dart';

class Questionnaire{
  final String? questionnaireTitle;
  final String? remark;
  final List<QuestionnaireQuestion> answeredQuestions;

  Questionnaire({
    this.questionnaireTitle,
    this.remark,
    required this.answeredQuestions,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    var list = json['answeredQuestions'] as List;
    List<QuestionnaireQuestion> questionsList = list.map((i) => QuestionnaireQuestion.fromJson(i)).toList();

    return Questionnaire(
      questionnaireTitle: json['questionnaireTitle'] as String,
      remark: json['remark'] as String,
      answeredQuestions: questionsList,
    );
  }

}


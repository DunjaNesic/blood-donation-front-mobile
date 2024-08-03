import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/models/question.dart';
import 'package:blood_donation/models/questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuestionnaireForAction extends StatefulWidget {
  final int actionID;
  final String? jmbg;

  const QuestionnaireForAction({super.key, required this.actionID, required this.jmbg});

  @override
  State<QuestionnaireForAction> createState() => _QuestionnaireForActionState();
}

class _QuestionnaireForActionState extends State<QuestionnaireForAction> {
  late Future<Questionnaire> _questionnaireFuture;
  late Future<Map<int, String>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionnaireFuture = fetchQuestionnaire();
    _questionsFuture = fetchQuestions();
  }

  Future<Map<int, String>> fetchQuestions() async {
    final response = await http.get(
      Uri.parse('https://10.87.0.161:7062/itk/donors/${widget.jmbg}/questionnaires/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> questionsJson = json.decode(response.body);
      final questions = questionsJson.map((json) => Question.fromJson(json)).toList();
      return {for (var question in questions) question.questionID: question.questionText ?? 'Unknown question'};
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<Questionnaire> fetchQuestionnaire() async {
    final response = await http.get(Uri.parse(
        'https://10.87.0.161:7062/itk/donors/${widget.jmbg}/questionnaires/${widget.actionID}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Questionnaire.fromJson(data);
    } else {
      throw Exception('Failed to load questionnaire');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: true,
      ),
      body: FutureBuilder<Map<int, String>>(
        future: _questionsFuture,
        builder: (context, questionsSnapshot) {
          if (questionsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (questionsSnapshot.hasError) {
            return Center(child: Text('Error: ${questionsSnapshot.error}'));
          } else {
            return FutureBuilder<Questionnaire>(
              future: _questionnaireFuture,
              builder: (context, questionnaireSnapshot) {
                if (questionnaireSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (questionnaireSnapshot.hasError) {
                  return Center(child: Text('Error: ${questionnaireSnapshot.error}'));
                } else {
                  final questionnaire = questionnaireSnapshot.data!;
                  final questions = questionsSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questionnaire.questionnaireTitle ?? "Naziv upitnika trenutno nije dostupan",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF490008),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text( "Komentar ili napomena zdravstvenog radnika: ${
                            questionnaire.remark ?? "/"
                        }",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: questionnaire.answeredQuestions.length,
                            itemBuilder: (context, index) {
                              final question = questionnaire.answeredQuestions[index];
                              final questionText = questions[question.questionID] ?? 'Pitanje trenutno nije dostupno';
                              final Color cardColor = question.answer
                                  ? Colors.red.withOpacity(0.4)
                                  : Colors.lightGreenAccent.withOpacity(0.4);
                              return Card(
                                color: cardColor,
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        questionText,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Vaš odgovor: ${question.answer ? "Da" : "Ne"}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      // bottomNavigationBar: const CustomNavBar(),
    );
  }
}

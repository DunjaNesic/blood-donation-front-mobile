import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blood_donation/models/question.dart';
import 'package:blood_donation/common/nav_bar.dart';
import 'package:blood_donation/common/app_bar.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  List<Question> _questions = [];
  final Map<int, bool> _answers = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7062/itk/donors/1104001765020/questionnaires/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> questionsJson = json.decode(response.body);
      setState(() {
        _questions = questionsJson.map((json) => Question.fromJson(json)).toList();
        for (var question in _questions) {
          _answers[question.questionID] = false;
        }
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<void> _submitQuestionnaire() async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7062/itk/donors/1104001765020/questionnaires/7'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'questionnaireTitle': 'string',
        'remark': 'string',
        'dateOfMaking': DateTime.now().toIso8601String(),
        'answers': _answers.values.toList(),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uspesno ste popunili upitnik. Sacekajte zdravstvenog radnika')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doslo je do greske u popunjavanju upitnika. Pokusajte ponovo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: true,
      ),
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ..._questions.asMap().entries.map((entry) {
            int index = entry.key;
            Question question = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${index + 1}. ${question.questionText ?? 'No question text'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12,),
                      CustomSwitch(
                        value: _answers[question.questionID] ?? false,
                        onChanged: (bool value) {
                          setState(() {
                            _answers[question.questionID] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _submitQuestionnaire,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64F472),
              ),
              child: const Text(
                "Gotovo",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: value ? Colors.red : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value ? 'Da' : 'Ne',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

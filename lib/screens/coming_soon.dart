import 'dart:convert';
import 'package:blood_donation/common/api_handler.dart';
import 'package:blood_donation/models/action.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/screens/creating_questionnaire.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  late Future<List<TransfusionAction>> futureActions;
  String userType = "";
  String? jmbg;

  Future<void> cancelAction(int actionID) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final userID = _prefs.getInt('id');

    if (userID == null) {
      print('AAAA');
    }
    final authUrl = '${BaseAPI.api}/auth/$userID';
    final authResponse = await http.get(Uri.parse(authUrl), headers: {'Content-Type': 'application/json'});

    if (authResponse.statusCode != 200) {
      throw Exception('Failed to fetch user information');
    }

    final authData = jsonDecode(authResponse.body);
    final volunteerID = authData['volunteerID'];
    String url;

    if (userType == 'Volunteer' && volunteerID != null && volunteerID != 0) {
      url = '${BaseAPI.api}/volunteers/$volunteerID/$actionID';
    } else if (userType == 'Donor' && jmbg != null) {
      url = '${BaseAPI.api}/donors/$jmbg/$actionID';
    } else {
      throw Exception('Invalid user type or missing identifiers');
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "acceptedTheCall": "false",
        "showedUp": "false",
      }),
    );

    final success = response.statusCode == 200;
      await _showDialog(context, success ? 'Uspesno ste otkazali svoj dolazak na akciju :(' : 'Trenutno ne mozete da otkazete svoj dolazak, pokusajte kasnije', success);
  }

  Future<void> _showDialog(BuildContext context, String message, bool success) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            success ? Icons.check_circle : Icons.cancel,
            color: success ? Colors.green : Colors.red,
            size: 48,
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                context.pop();
                if (success) {
                  setState(() {
                    futureActions = fetchActions();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<TransfusionAction>> fetchActions() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final userID = _prefs.getInt('id');

    if (userID == null) {
      print('AAAA');
    }
    final authUrl = '${BaseAPI.api}/auth/$userID';
    final authResponse = await http.get(Uri.parse(authUrl), headers: {'Content-Type': 'application/json'});

    if (authResponse.statusCode != 200) {
      throw Exception('Failed to fetch user information');
    }

    final authData = jsonDecode(authResponse.body);
    setState(() {
      userType = authData['userType'];
      jmbg = authData['jmbg'];
    });
    final volunteerID = authData['volunteerID'];
    String url;

    if (userType == 'Volunteer' && volunteerID != null && volunteerID != 0) {
      url = '${BaseAPI.api}/actions/incoming/${1}/${volunteerID}';
    } else if (userType == 'Donor' && jmbg != null) {
      url = '${BaseAPI.api}/actions/incoming/${0}/${jmbg}';
    } else {
      throw Exception('Invalid user type or missing identifiers');
    }

    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((action) => TransfusionAction.fromJson(action)).toList();
    } else if (response.statusCode == 404){
      //srediti output caching
      throw Exception('Niste prijavljeni ni za jednu akciju');
    }
    else {
      throw Exception('Trenutno ne mozemo da ucitamo vase akcije');
    }
  }

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    return '$days';
  }

  @override
  void initState() {
    super.initState();
    futureActions = fetchActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: false,
      ),
      body: Container(
        color: const Color(0xFFF1F5FC),
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
        child: FutureBuilder<List<TransfusionAction>>(
          future: futureActions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Prikaz akcija trenutno nije moguc'));
            } else {
              List<TransfusionAction> actions = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(13),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  TransfusionAction action = actions[index];
                  Duration timeUntilAction = action.actionDate.difference(DateTime.now());
                  String timeUntilActionFormatted = formatDuration(timeUntilAction);
                  bool isQuestionnaireButtonEnabled = timeUntilAction.inDays == 0;

                  return Column(
                    children: [
                      Card(
                        color: const Color(0xFF506EDA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26.0),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          action.placeName ?? 'Grad u kome se odrzava akcija bice naknadno upisan',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          action.actionName ?? 'O nazivu akcije bicete naknadno obavesteni',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          action.exactLocation ?? 'O tacnoj lokaciji bicete naknadno obavesteni',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const CircleAvatar(
                                    backgroundColor: Colors.pink,
                                    child: Text(
                                      'A+',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(height: 1),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${action.actionDate.day}.${action.actionDate.month}.${action.actionDate.year}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    action.actionTimeFromTo ?? 'Vreme odrzavanja akcije ce uskoro biti azurirano',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularPercentIndicator(
                                    radius: 40.0,
                                    lineWidth: 8.0,
                                    percent: timeUntilAction.inDays / 365,
                                    center: Text(
                                      timeUntilActionFormatted,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    progressColor: Colors.pink,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'dana do akcije',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () => cancelAction(action.actionID),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1908C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Otkaži',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (userType != 'Volunteer')
                                ElevatedButton(
                                onPressed: isQuestionnaireButtonEnabled
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          QuestionnaireScreen(
                                            actionID: action.actionID,
                                            jmbg: jmbg ?? '',
                                          ),
                                    ),
                                  );
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Popuni upitnik',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

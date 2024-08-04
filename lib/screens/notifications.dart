import 'package:blood_donation/common/api_handler.dart';
import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/models/action.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late Future<List<TransfusionAction>> futureActions;
  String userType = "";
  String JMBG = "";
  int? volunteerID;

  @override
  void initState() {
    super.initState();
    futureActions = _fetchActions();
  }

  Future<List<TransfusionAction>> _fetchActions() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final userID = _prefs.getInt('id');

    if (userID == null) {
      throw Exception('User ID is missing');
    }

    final authUrl = '${BaseAPI.api}/auth/$userID';
    final authResponse = await http.get(Uri.parse(authUrl), headers: {'Content-Type': 'application/json'});

    if (authResponse.statusCode != 200) {
      throw Exception('Failed to fetch user information');
    }

    final authData = jsonDecode(authResponse.body);
    setState(() {
      userType = authData['userType'];
      JMBG = authData['jmbg'] ?? '';
      volunteerID = authData['volunteerID'];
    });

    String url;
    if (userType == 'Volunteer' && volunteerID != null && volunteerID != 0) {
      url = '${BaseAPI.api}/volunteers/${volunteerID}/calls/false';
    } else if (userType == 'Donor' && JMBG.isNotEmpty) {
      url = '${BaseAPI.api}/donors/${JMBG}/calls/false';
    } else {
      return [];
    }

    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransfusionAction.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> _updateActionStatus(int actionID, bool accepted) async {
    if (userType.isEmpty || (userType == 'Donor' && JMBG.isEmpty) || (userType == 'Volunteer' && volunteerID == null)) {
      throw Exception('Invalid user type or identifier');
    }

    final url = userType == 'Donor'
        ? '${BaseAPI.api}/donors/$JMBG/$actionID'
        : '${BaseAPI.api}/volunteers/$volunteerID/$actionID';

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'acceptedTheCall': accepted,
        'showedUp': false,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update action status');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<TransfusionAction>>(
          future: futureActions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nemate pozive na akcije'));
            }

            return ListView(
              children: snapshot.data!.map((action) {
                return NotificationCard(
                  action: action,
                  onAccept: () async {
                    try {
                      await _updateActionStatus(action.actionID, true);
                      setState(() {
                        futureActions = _fetchActions();
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating action: $e')),
                      );
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final TransfusionAction action;
  final VoidCallback onAccept;

  const NotificationCard({
    required this.action,
    required this.onAccept,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action.actionName ?? '',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Location: ${action.placeName ?? ''}'),
            Text('Address: ${action.exactLocation ?? ''}'),
            Text('Date: ${DateFormat('dd.MM.yyyy').format(action.actionDate)}'),
            Text('Time: ${action.actionTimeFromTo ?? ''}'),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

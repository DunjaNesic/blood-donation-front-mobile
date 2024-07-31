import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/common/nav_bar.dart';
import 'package:blood_donation/models/action.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late Future<List<TransfusionAction>> futureActions;

  @override
  void initState() {
    super.initState();
    futureActions = fetchActions();
  }

  Future<List<TransfusionAction>> fetchActions() async {
    final response = await http.get(Uri.parse('https://10.0.2.2:7062/itk/donors/1104001765020/calls/false'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransfusionAction.fromJson(json)).toList();
    } else if (response.statusCode == 404) throw Exception('Trenutno nemate pozive na akcije');
    else {
      throw Exception('Doslo je do greske pri ucitavanju poziva na akciju');
    }
  }

  Future<void> updateActionStatus(int actionID, bool accepted) async {
    final response = await http.put(
      Uri.parse('https://10.0.2.2:7062/itk/donors/1104001765020/$actionID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'acceptedTheCall': accepted,
        'showedUp': false,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Greskaaaaaa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: true,
      ),
      bottomNavigationBar: const CustomNavBar(),
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
              return const Center(child: Text('No actions available'));
            }

            return ListView(
              children: snapshot.data!.map((action) {
                return NotificationCard(
                  action: action,
                  onAccept: () async {
                    try {
                      await updateActionStatus(action.actionID, true);
                      setState(() {
                        futureActions = fetchActions();
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Doslo je do greske pri ucitavanju poziva: $e')),
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
            Text('Lokacija: ${action.placeName ?? ''}'),
            Text('Adresa: ${action.exactLocation ?? ''}'),
            Text('Datum: ${DateFormat('dd.MM.yyyy').format(action.actionDate)}'),
            Text('Vreme: ${action.actionTimeFromTo ?? ''}'),
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
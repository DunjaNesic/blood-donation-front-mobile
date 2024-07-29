import 'dart:convert';
import 'package:blood_donation/models/action.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/common/nav_bar.dart';

class ComingSoonScreen extends StatefulWidget {
  final String userType;
  final String id;

  const ComingSoonScreen({super.key, required this.userType, required this.id});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  late Future<List<TransfusionAction>> futureActions;

  Future<List<TransfusionAction>> fetchActions() async {
    final response = await http.get(Uri.parse(
        'https://10.0.2.2:7062/itk/actions/incoming/${0}/1104001765020'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((action) => TransfusionAction.fromJson(action))
          .toList();
    } else {
      throw Exception('Failed to load actions');
    }
  }

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    return '$days dana';
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
            } else {
              List<TransfusionAction> actions = snapshot.data!;
              return ListView.builder(
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  TransfusionAction action = actions[index];
                  Duration timeUntilAction =
                  action.actionDate.difference(DateTime.now());
                  String timeUntilActionFormatted =
                  formatDuration(timeUntilAction);

                  return Card(
                    color: const Color(0xFF506EDA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action.exactLocation ?? 'Location Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    action.actionName ?? 'Action Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${action.actionDate.day}.${action.actionDate.month}.${action.actionDate.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                action.actionTimeFromTo ?? 'Time Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      timeUntilActionFormatted,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1908C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Otkaži'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}

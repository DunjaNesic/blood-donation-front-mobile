import 'dart:convert';
import 'package:blood_donation/common/api_handler.dart';
import 'package:blood_donation/models/donor_stats.dart';
import 'package:blood_donation/models/stats.dart';
import 'package:blood_donation/models/volunteer_stats.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:blood_donation/common/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Statistics> _statistics;
  String userType = "";
  String JMBG = "";
  int? volunteerID;
  String fullName = ""; // Add this variable to store the fullName

  @override
  void initState() {
    super.initState();
    _statistics = _fetchStatistics();
  }

  Future<Statistics> _fetchStatistics() async {
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
      url = '${BaseAPI.api}/volunteers/${volunteerID}/stats';
    } else if (userType == 'Donor' && JMBG.isNotEmpty) {
      url = '${BaseAPI.api}/donors/${JMBG}/stats';
    } else {
      throw Exception('Invalid user type or missing ID');
    }

    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final stats = jsonDecode(response.body);
      setState(() {
        fullName = stats['fullName'] ?? '';
      });

      if (userType == 'Donor') {
        return DonorStatistics.fromJson(stats);
      } else if (userType == 'Volunteer') {
        return VolunteerStatistics.fromJson(stats);
      } else {
        throw Exception('Unknown user type');
      }
    } else {
      throw Exception('Failed to load statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FC),
      appBar: const CustomAppBar(title: 'ITK FON'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: Image.asset(
                        'assets/images/stats.jpg',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName.isEmpty ? 'User Name' : fullName, // Use fullName variable
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Statistika sa svih Vaših akcija',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              'A-',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<Statistics>(
                future: _statistics,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final stats = snapshot.data!;
                    return Column(
                      children: [
                        _buildStatisticIndicator(
                          context,
                          percentage: stats.acceptedAndAttendedPercentage / 100,
                          label: 'Prihvatili ste poziv i pojavili ste se, bravo!!',
                          color: const Color(0xFF8593ED),
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: stats.acceptedButDidNotAttendPercentage / 100,
                          label: 'Prihvatili ste poziv ali se niste pojavili :(',
                          color: const Color(0xFFE42C64),
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: stats.declinedAndDidNotAttendPercentage / 100,
                          label: 'Odbili ste poziv i niste se pojavili',
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: stats.declinedButAttendedPercentage / 100,
                          label: 'Odbili ste poziv ali ste se ipak pojavili',
                          color: const Color(0xFF5A6ACF),
                        ),
                      ],
                    );
                  } else {
                    return const Text('No data available');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticIndicator(
      BuildContext context, {
        required double percentage,
        required String label,
        required Color color,
      }) {
    return Row(
      children: [
        CircularPercentIndicator(
          radius: 64.0,
          lineWidth: 13.0,
          percent: percentage,
          center: Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          progressColor: color,
          backgroundColor: Colors.grey[300]!,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

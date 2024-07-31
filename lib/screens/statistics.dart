import 'dart:convert';
import 'package:blood_donation/models/donor_stats.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;

import 'package:blood_donation/common/app_bar.dart';
import 'package:blood_donation/common/nav_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<DonorStatistics> _donorStatistics;

  @override
  void initState() {
    super.initState();
    _donorStatistics = fetchDonorStatistics();
  }

  Future<DonorStatistics> fetchDonorStatistics() async {
    final response = await http.get(
        Uri.parse('https://10.0.2.2:7062/itk/donors/1104001765020/stats'));

    if (response.statusCode == 200) {
      return DonorStatistics.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Greska pri ucitavanju statistika');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FC),
      appBar: const CustomAppBar(title: 'ITK FON'),
      bottomNavigationBar: const CustomNavBar(),
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
                        'assets/images/sa cvikerima.jpeg',
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
                                const Text(
                                  'Dunja Nešić',
                                  style: TextStyle(
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
              FutureBuilder<DonorStatistics>(
                future: _donorStatistics,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Column(
                      children: [
                        _buildStatisticIndicator(
                          context,
                          percentage: snapshot.data!.acceptedAndAttendedPercentage / 100,
                          label: 'Prihvatili ste poziv i pojavili ste se, bravo!!',
                          color: const Color(0xFF8593ED),
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: snapshot.data!.acceptedButDidNotAttendPercentage / 100,
                          label: 'Prihvatili ste poziv ali se niste pojavili :(',
                          color: const Color(0xFFE42C64),
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: snapshot.data!.declinedAndDidNotAttendPercentage / 100,
                          label: 'Odbili ste poziv i niste se pojavili',
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 24),
                        _buildStatisticIndicator(
                          context,
                          percentage: snapshot.data!.declinedButAttendedPercentage / 100,
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

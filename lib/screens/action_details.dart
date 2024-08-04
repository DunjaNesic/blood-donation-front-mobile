import 'package:blood_donation/common/api_handler.dart';
import 'package:flutter/material.dart';
import 'package:blood_donation/models/action.dart';
import 'package:blood_donation/common/app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ActionDetailsScreen extends StatelessWidget {
  final TransfusionAction action;

  const ActionDetailsScreen({required this.action, super.key});

  Future<void> _actionSignUp(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final userID = _prefs.getInt('id');

    if (userID == null) {
      await _showDialog(context, 'User ID not found', false);
      return;
    }

    final authUrl = '${BaseAPI.api}/auth/$userID';
    final authResponse = await http.get(Uri.parse(authUrl), headers: {'Content-Type': 'application/json'});

    if (authResponse.statusCode != 200) {
      await _showDialog(context, 'Failed to fetch user information', false);
      return;
    }

    final authData = jsonDecode(authResponse.body);
    final userType = authData['userType'];
    final jmbg = authData['jmbg'];
    final volunteerID = authData['volunteerID'];
    final actionId = action.actionID;
    String url;

    if (userType == 'Volunteer' && volunteerID != null && volunteerID != 0) {
      url = '${BaseAPI.api}/volunteers/$volunteerID/$actionId';
    } else if (userType == 'Donor' && jmbg != null) {
      url = '${BaseAPI.api}/donors/$jmbg/$actionId';
    } else {
      await _showDialog(context, 'Invalid user type or missing identifiers', false);
      return;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'key': 'value'}),
    );
    final res = response.statusCode;
    if (res == 451){
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "acceptedTheCall": "true",
          "showedUp": "false",
        }),
      );
      final success = response.statusCode == 200;
      final telo = response.body;
      await _showDialog(context, success ? '${response.body}' : 'Ne mozete vise da se prijavite za akciju, vec ste jednom bili prijavljeni', success);
    } else {
      await _showDialog(context, res == 200
          ? 'Uspesno ste se prijavili na akciju!'
          : 'Ne mozete se prijaviti za ovu akciju :(', res == 200);
    }
    if (context.mounted) {
      context.pop();
    }
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
              onPressed: () => context.pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'ITK FON', showBackButton: true,),
      body: Container(
        color: const Color(0xFFACB7E1),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  action.actionName ?? 'Izabranoj akciji jos uvek nije ozvanicen naziv',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF490008),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Tristique diam aliquet massa non quam augue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 42),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconWithText(
                      icon: Icons.calendar_today,
                      text: action.actionDate.toLocal().toString().split(' ')[0],
                    ),
                    const SizedBox(width: 16),
                    IconWithText(
                      icon: Icons.access_time,
                      text: action.actionTimeFromTo ?? "Vreme akcije je trenutno nepoznato",
                    ),
                  ],
                ),
                const SizedBox(height: 42),
                Row(
                  children: [
                    const Icon(Icons.location_pin, color: Color(0xFF506EDA), size: 26,),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        action.exactLocation ?? "Tacna lokacija ce biti naknadno javljena",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 92),
                ElevatedButton(
                  onPressed: () => _actionSignUp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1908C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
                    elevation: 8,
                  ),
                  child: const Text('Prijavi se za akciju', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconWithText({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF506EDA),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}

import 'package:blood_donation/models/action.dart';
import 'package:blood_donation/screens/view_questionnaire.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blood_donation/common/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  List<TransfusionAction> actions = [];
  String userType = "";
  String? JMBG = "";
  int? volunteerID;

  @override
  void initState() {
    super.initState();
    fetchActions();
  }

  Future<void> fetchActions() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final userID = _prefs.getInt('id');

    if (userID == null) {
      print('AAAA');
    }
    final authUrl = 'https://10.87.0.161:7062/itk/auth/$userID';
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
      url = 'https://10.87.0.161:7062/itk/volunteers/${volunteerID}/calls/true';
    } else if (userType == 'Donor' && JMBG != null) {
      url = 'https://10.87.0.161:7062/itk/donors/${JMBG}/calls/true';
    } else {
      throw Exception('Invalid user type or missing identifiers');
    }

    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        actions = data.map((json) => TransfusionAction.fromJson(json)).toList();
      });
    } else {
      throw Exception(
          'Doslo je do greske pri ucitavanju istorije akcija na kojima ste ucestvovali. Pokusajte kasnije');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'ITK FON',
        showBackButton: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Vaše učešće na akcijama",
              style: TextStyle(
                color: Color(0xFF490008),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          Expanded(
            child: buildActionList(actions, userType, JMBG),
          ),
        ],
      ),
    );
  }

  Widget buildActionList(List<TransfusionAction> actions, String userType, String? JMBG) {
    return ListView.separated(
      itemCount: actions.length,
      separatorBuilder: (context, index) => Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: const Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  DateFormat.MMM().format(action.actionDate),
                  style: const TextStyle(
                      fontSize: 16, color: Color(0xFF413F89)),
                ),
              ),
              Flexible(
                child: Text(
                  action.actionDate.day.toString(),
                  style: const TextStyle(
                      fontSize: 24, color: Color(0xFF413F89)),
                ),
              ),
            ],
          ),
          title: Text(
            action.actionName ?? 'Nepoznat naziv',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${action.placeName ?? 'Nepoznata lokacija'}, ${action.exactLocation ?? ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: userType == 'Donor'
              ? IconButton(
            icon: const Icon(Icons.insert_drive_file, color: Color(0xFF413F89)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuestionnaireForAction(actionID: action.actionID, jmbg: JMBG),
                ),
              );
            },
          )
              : null,
        );
      },
    );
  }
}

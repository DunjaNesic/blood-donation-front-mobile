import 'package:blood_donation/models/action.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActionCard extends StatelessWidget {
  final TransfusionAction action;

  const ActionCard({
    required this.action,
    super.key,
  });

  Future<TransfusionAction?> _fetchAction() async {
    final url = 'https://10.87.0.161:7062/itk/actions/${action.actionID}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final actionData = jsonDecode(response.body);
        final a = TransfusionAction.fromJson(actionData);
        return a;
      } else {
        print('Failed to load action details');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  void _navigateToDetails(BuildContext context) async {
    final detailedAction = await _fetchAction();
    if (detailedAction != null) {
      if (context.mounted) {
        context.push('/action_details', extra: detailedAction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF506EDA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokacija',
              style: TextStyle(color: Color(0xFFB6C6FF)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    action.exactLocation ?? "Lokacija je trenutno nedostupna",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.location_pin,
                  color: Color(0xFFE98E8D),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1.0,
              height: 20.0,
            ),
            Text(
              action.actionName ?? "Naziv lokacije je trenutno nepoznat",
              style: const TextStyle(color: Color(0xFFB6C6FF), fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                ElevatedButton(
                  onPressed: () => _navigateToDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A85DE),
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 2),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text(
                    'Detalji',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

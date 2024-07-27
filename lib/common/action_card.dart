import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String location;
  final String description;

  const ActionCard({
    required this.location,
    required this.description,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(location),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Detalji'),
        ),
      ),
    );
  }
}
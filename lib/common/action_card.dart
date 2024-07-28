import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String location;
  final String name;

  const ActionCard({
    required this.location,
    required this.name,
    super.key,
  });

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
                    location,
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
              name,
              style: const TextStyle(color: Color(0xFFB6C6FF), fontSize: 16),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            Row(
              children: [
                const Expanded(child: SizedBox()), // Spacer to push the button to the right
                ElevatedButton(
                  onPressed: () {},
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

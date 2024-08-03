import 'package:blood_donation/common/nav_bar.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const CustomScaffold({super.key, required this.body, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: CustomNavBar(currentIndex: currentIndex),
    );
  }
}

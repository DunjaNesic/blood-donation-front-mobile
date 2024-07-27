import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CustomAppBar({required this.title, this.height = kToolbarHeight, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/logo2.gif',
          height: height * 0.6,
          width: height * 0.6,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF490008)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
      ],
      backgroundColor: const Color(0xFFF1F5FC),
      shadowColor: Colors.blueGrey,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
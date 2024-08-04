import 'package:blood_donation/screens/intro.dart';
import 'package:blood_donation/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;
  final bool showBackButton;

  const CustomAppBar({
    required this.title,
    this.height = kToolbarHeight,
    this.showBackButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      )
          : Padding(
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
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Notifications()));
          },
        ),
        IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              _prefs.remove('id');
              _prefs.remove('token');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Intro()));
            })
      ],
      backgroundColor: const Color(0xFFF1F5FC),
      shadowColor: Colors.blueGrey,
      elevation: 1,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FC),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                Image.asset(
                  'assets/images/logo2.gif', // Update with your actual asset path
                  height: 170,
                ),
                const SizedBox(height: 24),
                const Text(
                  'ITK FON',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Color(0xFF490008),
                  ),
                ),
                const SizedBox(height: 100),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () => {context.pushReplacement('/login')},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFF1F5FC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: const BorderSide(color: Color(0xFFD80032)),
                      ),
                    ),
                    child: const Text(
                      'Prijavi se',
                      style: TextStyle(color: Color(0xFFD80032)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () => {context.pushReplacement('/register')},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFD80032),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Kreiraj svoj nalog',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/waves.png', // Update with your actual asset path
            fit: BoxFit.cover,
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            height: 170,
          ),
        ],
      ),
    );
  }
}

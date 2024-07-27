import 'package:flutter/material.dart';

class CustomErrorText extends StatelessWidget {
  final String? errorText;

  const CustomErrorText({this.errorText, super.key});

  @override
  Widget build(BuildContext context) {
    return errorText != null
        ? Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        errorText!,
        style: const TextStyle(color: Color(0xFFD80032), fontWeight: FontWeight.bold),
      ),
    )
        : const SizedBox.shrink();
  }
}

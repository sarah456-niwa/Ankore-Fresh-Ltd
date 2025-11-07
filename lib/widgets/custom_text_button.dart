// widgets/custom_text_button.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
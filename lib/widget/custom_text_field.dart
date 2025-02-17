import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;

  CustomTextField({
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400], // Gray label text
          ),
        ),
        SizedBox(height: 6), // Space between the label and the text field
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25), // Rounded corners
              borderSide: BorderSide(
                  color: Colors.grey, width: 1.0), // Custom border color
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                  color: Colors.grey, width: 1.0), // Custom border color
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(
                  color: Colors.orange, width: 1.5), // Blue border on focus
            ),
            filled: true,
            fillColor: Colors.white, // White background for the field
          ),
        ),
      ],
    );
  }
}


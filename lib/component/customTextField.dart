import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final Color borderColor;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  CustomTextField({
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
    this.borderColor = Colors.grey,
    this.validator,
    this.onSaved,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      decoration: InputDecoration(
        
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.orange, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
      ],);

  }
}

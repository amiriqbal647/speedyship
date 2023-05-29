import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final TextInputType keyboardType;
  final String hintText;
  final bool obscureText;
  final bool readOnly;

  const MyTextField(
      {super.key,
      required this.controller,
      this.validator,
      this.onTap,
      required this.hintText,
      required this.obscureText,
      required this.keyboardType,
      required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.transparent, width: 0)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.transparent, width: 0)),
        filled: true,
        hintText: hintText,
      ),
    );
  }
}

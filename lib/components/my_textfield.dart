import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function()? onTap;
  final TextInputType keyboardType;
  final String hintText;
  final String? placeholder;
  final bool obscureText;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextField({
    Key? key,
    required this.controller,
    this.validator,
    this.onTap,
    required this.hintText,
    this.placeholder,
    required this.obscureText,
    required this.keyboardType,
    required this.readOnly,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        filled: true,
        hintText: placeholder ?? hintText,
      ),
    );
  }
}

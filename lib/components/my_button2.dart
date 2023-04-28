import 'package:flutter/material.dart';

class MyButton2 extends StatelessWidget {
  final Function()? onTap;

  const MyButton2({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: Colors.orange[700],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
            child: Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )),
      ),
    );
  }
}

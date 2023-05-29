import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;

  const MyButton({super.key, this.onTap, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
            fixedSize: Size(90.w, 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Text(buttonText));
  }
}

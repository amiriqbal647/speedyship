import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final Function()? onPressed;
  final String imagepath;
  final String buttonText;
  const MyElevatedButton(
      {super.key,
      this.onPressed,
      required this.imagepath,
      required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          fixedSize: Size(90.w, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagepath,
            height: 24,
            width: 24,
          ),
          const SizedBox(
            width: 15,
          ),
          Text(buttonText)
        ],
      ),
    );
  }
}

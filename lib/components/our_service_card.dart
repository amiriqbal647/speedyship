import 'package:flutter/material.dart';

class OurServiceCard extends StatelessWidget {
  //final String imagepath;
  final String cardText;
  const OurServiceCard({super.key, required this.cardText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 240,
      child: Card(
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        elevation: 5,
        margin: const EdgeInsets.fromLTRB(0, 10, 15, 10),
        child: Column(
          children: [
            // Image.asset(
            //   '',
            //   height: 150,
            //   width: double.infinity,
            //   fit: BoxFit.cover,
            // ),
            Text(cardText)
          ],
        ),
      ),
    );
  }
}

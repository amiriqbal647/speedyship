import 'package:flutter/material.dart';

class OurServiceCard extends StatelessWidget {
  final String imagepath;
  final String cardText;
  const OurServiceCard(
      {super.key, required this.cardText, required this.imagepath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      width: 220,
      child: Card(
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        elevation: 5,
        margin: const EdgeInsets.fromLTRB(0, 10, 15, 10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Image.asset(
                imagepath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Text(
                cardText,
                style: Theme.of(context).textTheme.titleMedium,
              )
            ],
          ),
        ),
      ),
    );
  }
}

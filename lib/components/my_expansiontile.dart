import 'package:flutter/material.dart';

class MyExpansionTile extends StatelessWidget {
  final String title;
  final List<String> details;

  MyExpansionTile({required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary, fontSize: 24)),
      children: details
          .map(
            (detail) => Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Text(
                detail,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
          .toList(),
    );
  }
}

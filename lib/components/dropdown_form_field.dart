import 'package:flutter/material.dart';

class MyDropdownButtonFormField extends StatelessWidget {
  final String selectedOption;
  final Function(String?) onChanged;

  MyDropdownButtonFormField({
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Select an option',
        border: OutlineInputBorder(),
      ),
      value: selectedOption,
      items: [
        DropdownMenuItem(
          value: 'food',
          child: Text('Food'),
        ),
        DropdownMenuItem(
          value: 'electronic',
          child: Text('Electronic'),
        ),
        DropdownMenuItem(
          value: 'toys',
          child: Text('Toys & Games'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

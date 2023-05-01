import 'package:flutter/material.dart';

class MyCityDropdownButtonFormField extends StatelessWidget {
  final String selectedOption;
  final Function(String?) onChanged;

  MyCityDropdownButtonFormField({
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: 'Select your city',
        border: OutlineInputBorder(),
      ),
      value: selectedOption,
      items: [
        DropdownMenuItem(
          value: 'magusa',
          child: Text('Magusa'),
        ),
        DropdownMenuItem(
          value: 'lefkosa',
          child: Text('Lefkosa'),
        ),
        DropdownMenuItem(
          value: 'girne',
          child: Text('Girne'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

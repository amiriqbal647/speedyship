import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;

  const MyDatePicker({Key? key, required this.onDateSelected, this.validator})
      : super(key: key);

  @override
  _MyDatePickerState createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dobController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected(picked);
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        _errorText = widget.validator?.call(_dobController.text);
      });
    }
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date.';
    }

    final DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(value);
    final DateTime now = DateTime.now();

    if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Please select a date that is not before today.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dobController,
          decoration: InputDecoration(
            hintText: 'Date of Birth',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
            ),
            filled: true,
            errorText: _errorText,
          ),
          validator: widget.validator ?? validateDate,
        ),
      ),
    );
  }
}

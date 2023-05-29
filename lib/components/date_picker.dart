import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final bool isDateOfBirth;

  const MyDatePicker({
    Key? key,
    required this.onDateSelected,
    this.isDateOfBirth = false,
  }) : super(key: key);

  @override
  _MyDatePickerState createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dobController = TextEditingController();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.isDateOfBirth
          ? DateTime.now().subtract(Duration(days: 16 * 365)) // 16 years ago
          : DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected(picked);
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        errorMessage = null; // Clear any previous error message
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AbsorbPointer(
              child: TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  hintText: "Date of Birth",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                ),
                validator: (value) {
                  if (widget.isDateOfBirth) {
                    final selectedDate = DateFormat('yyyy-MM-dd').parse(value!);
                    final currentDate = DateTime.now();
                    var age = currentDate.year - selectedDate.year;
                    if (currentDate.month < selectedDate.month ||
                        (currentDate.month == selectedDate.month &&
                            currentDate.day < selectedDate.day)) {
                      age--;
                    }
                    if (age < 16) {
                      setState(() {
                        errorMessage = 'Must be at least 16 years old';
                      });
                    } else {
                      errorMessage =
                          null; // Clear the error message if age is valid
                    }
                  }
                  return null;
                },
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

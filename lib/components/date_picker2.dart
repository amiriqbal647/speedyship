import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDatePickerTwo extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const MyDatePickerTwo({Key? key, required this.onDateSelected})
      : super(key: key);

  @override
  _MyDatePickerTwoState createState() => _MyDatePickerTwoState();
}

class _MyDatePickerTwoState extends State<MyDatePickerTwo> {
  DateTime _selectedDate = DateTime.now();
  TextEditingController _dobcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dobcontroller.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
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
        _dobcontroller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dobcontroller,
          decoration: InputDecoration(
            hintText: "Date of Birth",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 0)),
            filled: true,
          ),
        ),
      ),
    );
  }
}

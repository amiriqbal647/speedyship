import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCourierProfilePage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;

  EditCourierProfilePage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
  });

  @override
  _EditCourierProfilePageState createState() => _EditCourierProfilePageState();
}

class _EditCourierProfilePageState extends State<EditCourierProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  late String _firstName;
  late String _lastName;
  late String _email;
  late String _phoneNumber;
  late String _dateOfBirth;

  final Color primaryColor = Color.fromRGBO(0, 147, 120, 1);
  final Color secondaryColor = Color.fromRGBO(231, 123, 0, 1);

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _email = widget.email;
    _phoneNumber = widget.phoneNumber;
    _dateOfBirth = widget.dateOfBirth;
  }

  void updateUser() {
    usersRef.doc(widget.userId).update({
      'firstName': _firstName,
      'lastName': _lastName,
      'email': _email,
      'phoneNumber': _phoneNumber,
      'dateOfBirth': _dateOfBirth,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text('Edit Courier Profile', style: TextStyle(color: primaryColor)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTextFormField('First Name', _firstName, (value) {
                setState(() {
                  _firstName = value;
                });
              }),
              SizedBox(height: 16.0),
              buildTextFormField('Last Name', _lastName, (value) {
                setState(() {
                  _lastName = value;
                });
              }),
              SizedBox(height: 16.0),
              buildTextFormField('Email', _email, (value) {
                setState(() {
                  _email = value;
                });
              }),
              SizedBox(height: 16.0),
              buildTextFormField('Phone Number', _phoneNumber, (value) {
                setState(() {
                  _phoneNumber = value;
                });
              }),
              SizedBox(height: 16.0),
              buildTextFormField('Date of Birth', _dateOfBirth, (value) {
                setState(() {
                  _dateOfBirth = value;
                });
              }),
              SizedBox(height: 32.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateUser();
                    Navigator.pop(context,
                        true); // Return true to indicate successful update
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Update', style: TextStyle(fontSize: 18.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(
      String label, String initialValue, Function(String) onChanged) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}

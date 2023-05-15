import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserPage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;

  EditUserPage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required phoneNumber,
    required dateOfBirth,
    required imageUrl,
  });

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  late String _firstName;
  late String _lastName;
  late String _email;

  final Color primaryColor = Color.fromRGBO(0, 147, 120, 1);
  final Color secondaryColor = Color.fromRGBO(231, 123, 0, 1);

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _email = widget.email;
  }

  void updateUser() {
    usersRef.doc(widget.userId).update({
      'firstName': _firstName,
      'lastName': _lastName,
      'email': _email,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit User', style: TextStyle(color: primaryColor)),
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
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateUser();
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: secondaryColor, // background
                  onPrimary: Colors.white, // foreground
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // round corners
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  child: Text('Save Changes'),
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
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $label';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EditUserInfo extends StatefulWidget {
  @override
  _EditUserInfoState createState() => _EditUserInfoState();
}

class _EditUserInfoState extends State<EditUserInfo> {
  final _formKey = GlobalKey<FormState>();
  late User loggedInUser;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  late DateTime dateOfBirth;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      loggedInUser = user;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedInUser.uid)
          .get();
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      String? firstName = data?['firstName'] as String?;
      String? lastName = data?['lastName'] as String?;
      String? email = data?['email'] as String?;
      String? phoneNumber = data?['PhoneNumber'] as String?;
      Timestamp? dobTimestamp = data?['DateOfBirth'] as Timestamp?;
      dateOfBirth = dobTimestamp?.toDate() ?? DateTime.now();
      String? imageUrl = data?['image'] as String?;
      this.setState(() {
        this.imageUrl = imageUrl ?? '';
      });

      firstNameController.text = firstName ?? '';
      lastNameController.text = lastName ?? '';
      emailController.text = email ?? '';
      phoneNumberController.text = phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Info'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 100,
              width: 100,
            ), //display the image here
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone number',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your new phone number';
                }
                return null;
              },
            ),
            SizedBox(
              height: 10,
            ),
            // MyDatePicker(
            //   onDateSelected: (newDate) {
            //     setState(() {
            //       dateOfBirth = newDate;
            //     });
            //   },
            // ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateUserInfo();
                  Navigator.pop(context);
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void updateUserInfo() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser.uid)
        .update({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'PhoneNumber': phoneNumberController.text.trim(),
      'DateOfBirth': dateOfBirth
    });
  }
}

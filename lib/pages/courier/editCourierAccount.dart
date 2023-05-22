import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  late String userId;

  // Retrieve user information from Firestore
  Future<void> retrieveUserInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        setState(() {
          firstNameController.text = data['firstName'];
          lastNameController.text = data['lastName'];
          emailController.text = data['email'];
          phoneNumberController.text = data['PhoneNumber'];
          dateOfBirthController.text = data['DateOfBirth'];
        });
      }
    }
  }

  // Update user information in Firestore
  Future<void> updateUserInfo() async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'email': emailController.text,
      'PhoneNumber': phoneNumberController.text,
      'DateOfBirth': dateOfBirthController.text,
    });
  }

  // Retrieve the ID of the currently logged-in user
  User? getCurrentUser() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    User? currentUser = getCurrentUser();

    if (currentUser != null) {
      userId = currentUser.uid;
      retrieveUserInfo();
    } else {
      // Handle the case where the user is not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: dateOfBirthController,
              decoration: InputDecoration(labelText: "Date of Birth"),
            ),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                updateUserInfo();
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

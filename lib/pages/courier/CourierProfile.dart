import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/pages/courier/editCourierAccount.dart';
import 'package:speedyship/pages/user/EditProfile.dart';

class CourierProfilePage extends StatefulWidget {
  @override
  _CourierProfilePageState createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
  final Color primaryColor = Color(0xFF009378);
  final Color accentColor = Color(0xFFE77B00);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      // User is not logged in
      return Scaffold(
        body: Center(
          child: Text('Courier not logged in'),
        ),
      );
    }

    String loggedInUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Courier Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong',
                    style: TextStyle(color: Colors.black)));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(
                child: Text('Courier data not found',
                    style: TextStyle(color: Colors.black)));
          }

          final firstName = userData['firstName'];
          final lastName = userData['lastName'];
          final email = userData['email'];
          final phoneNumber = userData['phoneNumber'];
          final dateOfBirth = userData['dateOfBirth'].toString();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: [
              Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: accentColor,
                            child: Text(
                              '${firstName[0]}${lastName[0]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$firstName $lastName',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    )),
                                SizedBox(height: 10),
                                Text('Email: $email',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    )),
                                SizedBox(height: 5),
                                Text(
                                  'Phone: ${phoneNumber ?? 'No phone number'}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text('DOB: $dateOfBirth',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () async {
                          bool result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCourierProfilePage(
                                userId: currentUser.uid,
                                firstName: firstName,
                                lastName: lastName,
                                email: email,
                                phoneNumber: phoneNumber,
                                dateOfBirth: dateOfBirth,
                              ),
                            ),
                          );

                          if (result == true) {
                            // Refresh the profile page or perform any other action
                            setState(() {
                              // Update the profile page with new data
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

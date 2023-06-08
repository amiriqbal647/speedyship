import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/pages/courier/editCourierAccount.dart';
import 'package:speedyship/pages/user/EditProfile.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:speedyship/components/my_button.dart';

class CourierProfilePage extends StatefulWidget {
  @override
  _CourierProfilePageState createState() => _CourierProfilePageState();
}

class _CourierProfilePageState extends State<CourierProfilePage> {
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
      appBar: AppBar(title: const Text('Courier account')),
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
                child: Text('User data not found',
                    style: TextStyle(color: Colors.black)));
          }

          final firstName = userData['firstName'];
          final lastName = userData['lastName'];
          final email = userData['email'];
          final phoneNumber = userData['PhoneNumber'];
          final dateOfBirth = userData['DateOfBirth'].toString();

          return Device.screenType == ScreenType.tablet
              ?
              //Desktop view*************************
              Center(
                  child: SizedBox(
                    width: 50.w,
                    child: ListView(
                      children: [
                        //Full name and circular avatar card
                        Card(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          elevation: 2,
                          margin: const EdgeInsets.all(15.0),
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(15.0, 30, 15.0, 30),
                            child: Column(
                              children: [
                                //Circular Avatar
                                CircleAvatar(
                                  radius: 50,
                                  child: Text(
                                    '${firstName[0]}${lastName[0]}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                //Full Name
                                Text('$firstName $lastName',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                              ],
                            ),
                          ),
                        ),

                        // Email phone dob card
                        Card(
                          elevation: 2,
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          margin: const EdgeInsets.all(15.0),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                //Email
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('Email'),
                                  subtitle: Text('$email'),
                                ),
                                //Phone
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: const Text('Phone'),
                                  subtitle: Text(
                                      '${phoneNumber ?? 'No phone number'}'),
                                ),
                                //Dob
                                ListTile(
                                  leading: const Icon(Icons.date_range),
                                  title: const Text('Date of birth'),
                                  subtitle: Text('$dateOfBirth'),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //Edit button
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: MyButton(
                            buttonText: 'Edit',
                            onTap: () async {
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
                        )
                      ],
                    ),
                  ),
                )
              :
              //Mobile view**********************
              ListView(
                  children: [
                    //Full name and circular avatar card
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 2,
                      margin: const EdgeInsets.all(15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            //Circular Avatar
                            CircleAvatar(
                              radius: 50,
                              child: Text(
                                '${firstName[0]}${lastName[0]}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            //Full Name
                            Text('$firstName $lastName',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                          ],
                        ),
                      ),
                    ),

                    // Email phone dob card
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 2,
                      margin: const EdgeInsets.all(15.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            //Email
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text('$email'),
                            ),
                            //Phone
                            ListTile(
                              leading: const Icon(Icons.phone),
                              title: const Text('Phone'),
                              subtitle:
                                  Text('${phoneNumber ?? 'No phone number'}'),
                            ),
                            //Dob
                            ListTile(
                              leading: const Icon(Icons.date_range),
                              title: const Text('Date of birth'),
                              subtitle: Text('$dateOfBirth'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Edit button
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: MyButton(
                        buttonText: 'Edit',
                        onTap: () async {
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
                    )
                  ],
                );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/pages/admin/editUser.dart';
import 'package:speedyship/pages/admin/edit_courier_page.dart';

// CourierDashboard
class CourierDashboard extends StatefulWidget {
  @override
  _CourierDashboardState createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  final Color primaryColor = Color(0xFF009378);
  final Color accentColor = Color(0xFFE77B00);

  void deleteUser(String userId) {
    usersRef.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courier List', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.where('role', isEqualTo: 'courier').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> users = snapshot.data!.docs
              .map<Map<String, dynamic>>(
                  (doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = snapshot.data!.docs[index].id;
              final firstName =
                  user is Map ? user['firstName'] : (user as dynamic)[0];
              final lastName =
                  user is Map ? user['lastName'] : (user as dynamic)[1];
              final email = user is Map ? user['email'] : (user as dynamic)[2];
              final phoneNumber =
                  user is Map ? user['PhoneNumber'] : (user as dynamic)[3];
              final dateOfBirth = user is Map
                  ? user['DateOfBirth'].toString()
                  : (user as dynamic)[4].toString();
              final overallRating = user is Map ? user['overallRating'] : null;

              return Card(
                elevation: 5.0,
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                SizedBox(height: 5),
                                Text(
                                    'Overall Rating: ${overallRating.toStringAsFixed(2) ?? "N/A"}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditCourierPage(
                                    userId: userId,
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    dateOfBirth: dateOfBirth,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(
                                        'Are you sure you want to delete this user?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Delete'),
                                        onPressed: () {
                                          deleteUser(userId);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

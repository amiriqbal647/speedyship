import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'delete_user_dialog.dart';

class User {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String dateOfBirth;
  String role; // New field for role

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.role, // Added role parameter
  });
}

class CourierDashboard extends StatefulWidget {
  @override
  _CourierDashboardState createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    final List<User> allUsers = snapshot.docs
        .map((doc) => User(
              firstName: doc['firstName'] as String? ?? '',
              lastName: doc['lastName'] as String? ?? '',
              email: doc['email'] as String? ?? '',
              phoneNumber: doc['PhoneNumber'] as String? ?? '',
              dateOfBirth: doc['DateOfBirth'] as String? ?? '',
              role: doc['role'] as String? ?? '', // Assign the role value
            ))
        .toList();

    final List<User> courierUsers =
        allUsers.where((user) => user.role == 'courier').toList();

    setState(() {
      this.users = courierUsers;
    });
  }

  void deleteUser(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteUserDialog(
          onDelete: () {
            setState(() {
              users.remove(user);
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void editUser(BuildContext context, User user) {
    // Edit user logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(9, 147, 120, 1.0),
        title: Text('Courier Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.fromRGBO(9, 147, 120, 1.0),
                        child: Text(
                          '${user.firstName[0]}${user.lastName[0]}'
                              .toUpperCase(),
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          Text(user.phoneNumber),
                          Text(user.dateOfBirth),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 18, 146, 77),
                          ),
                          onPressed: () {
                            editUser(context, user);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 222, 114, 25),
                          ),
                          onPressed: () {
                            deleteUser(user);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

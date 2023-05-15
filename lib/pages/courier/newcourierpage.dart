import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'UserFileListPage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String status;

  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.status});
}

class NewCourierPage extends StatefulWidget {
  @override
  _NewCourierPageState createState() => _NewCourierPageState();
}

class _NewCourierPageState extends State<NewCourierPage> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  void _getUsers() async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await usersRef.where('status', isEqualTo: 'pending').get();
    final users = querySnapshot.docs
        .map((doc) => User(
            id: doc.id,
            firstName: doc.get('firstName'),
            lastName: doc.get('lastName'),
            status: doc.get('status')))
        .toList();

    setState(() {
      _users = users;
    });
  }

  Future<void> _approveUser(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.id);
    await userRef.update({'role': 'courier'});
    await userRef.update({
      'status': FieldValue.delete(),
    });

    setState(() {
      _users.remove(user);
    });
  }

  Future<void> _denyUser(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.id);
    await userRef.update({'status': FieldValue.delete()});
    setState(() {
      _users.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF009378),
        title: Text('New Courier'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5, // Add shadow to the card
            child: Column(
              children: [
                ListTile(
                  title: Text('${user.firstName} ${user.lastName}',
                      style: TextStyle(
                          color:
                              Colors.black)), // user name text color is black
                  subtitle: Text('Status: ${user.status}',
                      style: TextStyle(color: Color(0xFFE77B00))),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserFileListPage(
                          userId: user.id,
                          firstName: user.firstName,
                          lastName: user.lastName,
                        ),
                      ),
                    );
                  },
                ),
                ButtonBar(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF009378),
                      ),
                      onPressed: () => _approveUser(user),
                      child: Text('Approve'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFE77B00),
                      ),
                      onPressed: () => _denyUser(user),
                      child: Text('Deny'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

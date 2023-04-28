import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/pages/admin/editUser.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  void deleteUser(String userId) {
    usersRef.doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
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
              final dateOfBirth =
                  user is Map ? user['DateOfBirth'] : (user as dynamic)[4];
              final imageUrl =
                  user is Map ? user['image'] : (user as dynamic)[5];

              return ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Text('No image'),
                ),
                title: Text('$firstName $lastName'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    phoneNumber != null
                        ? Text(phoneNumber)
                        : Text('No phone number'),
                    dateOfBirth != null
                        ? Text(dateOfBirth)
                        : Text('No date of birth provided for this user'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserPage(
                              userId: userId,
                              firstName: firstName,
                              lastName: lastName,
                              email: email,
                              phoneNumber: phoneNumber,
                              dateOfBirth: dateOfBirth,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteUser(userId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

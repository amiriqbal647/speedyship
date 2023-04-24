import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  //signout
  void signout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('My Flutter App'),
          actions: [IconButton(onPressed: signout, icon: Icon(Icons.logout))],
        ),
        body: Center(
          child: Text(
            'Welcome to my Flutter app!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        User? user = _auth.currentUser;
        if (user != null && !user.emailVerified) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Email Not Verified'),
                content: Text(
                    'Please verify your email before resetting your password.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          await _auth.sendPasswordResetEmail(email: _email);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Password Reset Email Sent'),
                content:
                    Text('Please check your email to reset your password.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_auth.currentUser != null &&
                  !_auth.currentUser!.emailVerified)
                Text(
                  'Please verify your email before resetting your password.',
                  style: TextStyle(color: Colors.red),
                ),
              Text(
                'Did you forget your password? write your Email and we will send you a reset link.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 16.0),
              FilledButton(
                onPressed: _resetPassword,
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
        //username
      ),
    );
  }
}

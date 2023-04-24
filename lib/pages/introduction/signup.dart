import 'package:flutter/material.dart';
import 'package:speedyship/components/my_textfield.dart';
import 'package:speedyship/components/square_tile.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:speedyship/components/my_button2.dart';
import 'package:speedyship/pages/auth.dart';
import 'package:speedyship/pages/introduction/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  //text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final repeatController = TextEditingController();

  final fnameController = TextEditingController();

  final lnameController = TextEditingController();

  //sign up a user
  Future<void> signup() async {
    try {
      // Create user account
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Add user data to Firestore collection
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'email': emailController.text,
        'firstName': fnameController.text,
        'lastName': lnameController.text,
      });

      // Navigate to the next page after a successful sign-up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle sign-up errors here
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  //rest of the code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              //logo
              Image.asset('lib/images/speedyshiptp.png'),

              const SizedBox(height: 50),
              //welcome back
              Text(
                'Welcome to SpeedyShip!',
                style: TextStyle(color: Colors.grey[700], fontSize: 18),
              ),

              const SizedBox(height: 25),
              //username
              MyTextField(
                controller: emailController,
                hintText: 'Email Address',
                obscureText: false,
              ),

              const SizedBox(height: 15),
              //pwd
              MyTextField(
                controller: passwordController,
                hintText: 'password',
                obscureText: true,
              ),

              const SizedBox(height: 15),
              //repeat
              MyTextField(
                  controller: repeatController,
                  hintText: 'Repeat your password',
                  obscureText: true),

              const SizedBox(height: 15),

              //firstname
              MyTextField(
                controller: fnameController,
                hintText: 'First Name',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              MyTextField(
                controller: lnameController,
                hintText: 'Last Name',
                obscureText: false,
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              ),

              const SizedBox(height: 25),
              //sign in button
              MyButton2(onTap: () => signup()),
              const SizedBox(height: 50),
              //or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[500],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[500],
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 50),
              //google and apple sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  //google button
                  SquareTile(
                    imagepath: 'lib/images/google.png',
                  ),
                  SizedBox(width: 20),
                  //apple button
                  SquareTile(
                    imagepath: 'lib/images/apple.png',
                  ),
                ],
              ),

              const SizedBox(height: 50),

              //not a mem? register

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Sign in now',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

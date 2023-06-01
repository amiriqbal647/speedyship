import 'dart:io';

// import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedyship/components/my_textfield.dart';
import 'package:speedyship/components/square_tile.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:speedyship/components/my_button2.dart';
import 'package:speedyship/pages/auth.dart';
import 'package:speedyship/components/date_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:speedyship/pages/introduction/login.dart';
import 'package:speedyship/services/auth_service.dart';
import '../../components/image_picker.dart';
import 'package:speedyship/services/auth_service.dart';
import 'package:speedyship/components/my_elevated_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignupPage extends StatefulWidget {
  SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  DateTime? _selectedDate;
  //text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final repeatController = TextEditingController();

  final fnameController = TextEditingController();

  final lnameController = TextEditingController();

  final phonecontroller = TextEditingController();

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
      final selectedDate = _selectedDate?.toIso8601String();

      // Add user data to Firestore collection
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'email': emailController.text,
        'firstName': fnameController.text,
        'lastName': lnameController.text,
        'PhoneNumber': phonecontroller.text,
        'DateOfBirth': selectedDate,
        'image': imageUrl,
        'role': 'user',
      });

      //Login a user after they sign up
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

  String imageUrl = '';
  String? emailErrorMessage; // Declare a variable to hold the error message

  bool _isValidEmail(String value) {
    final emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(value);
  }

  //rest of the code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Device.screenType == ScreenType.tablet
              ? Center(
                  child: SizedBox(
                    width: 40.w,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Sign Up to Speedyship',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),

                          Row(
                            children: [
                              Text(
                                'Already have an account?',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              InkWell(
                                child: Text(
                                  'Log in',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 16),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          //image picker
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: Stack(
                                children: [
                                  if (imageUrl != null && imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        imageUrl,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (imageUrl == null || imageUrl.isEmpty)
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 80,
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.camera),
                                        color: Colors.grey[600],
                                        onPressed: () async {
                                          String imageUrl = await uploadImage();
                                          setState(() {
                                            this.imageUrl = imageUrl;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          //username

                          MyTextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            hintText: 'Email Address',
                            obscureText: false,
                            readOnly: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email address';
                              } else if (!_isValidEmail(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null; // Return null if the input is valid
                            },
                          ),
                          const SizedBox(height: 15),
                          //pwd
                          MyTextField(
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            readOnly: false,
                          ),

                          const SizedBox(height: 15),
                          //repeat
                          MyTextField(
                            keyboardType: TextInputType.text,
                            controller: repeatController,
                            hintText: 'Repeat your password',
                            obscureText: true,
                            readOnly: false,
                          ),

                          const SizedBox(height: 15),

                          //firstname
                          MyTextField(
                            keyboardType: TextInputType.text,
                            controller: fnameController,
                            hintText: 'First Name',
                            obscureText: false,
                            readOnly: false,
                          ),

                          const SizedBox(height: 15),
                          //last name
                          MyTextField(
                            keyboardType: TextInputType.text,
                            controller: lnameController,
                            hintText: 'Last Name',
                            obscureText: false,
                            readOnly: false,
                          ),

                          const SizedBox(height: 15),
                          //dob
                          MyDatePicker(
                            onDateSelected: (date) => setState(
                              () => _selectedDate = date,
                            ),
                          ),

                          const SizedBox(height: 15),
                          //Phone no
                          MyTextField(
                            keyboardType: TextInputType.number,
                            controller: phonecontroller,
                            hintText: "Phone Number",
                            obscureText: false,
                            readOnly: false,
                          ),

                          const SizedBox(height: 25),
                          //sign in button
                          Center(
                            child: MyButton(
                              onTap: () => signup(),
                              buttonText: 'Sign Up',
                            ),
                          ),
                          const SizedBox(height: 15),
                          //or continue with
                          Row(
                            children: [
                              Expanded(
                                child: const Divider(
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'Or continue using',
                                ),
                              ),
                              const Expanded(
                                  child: Divider(
                                thickness: 1,
                              ))
                            ],
                          ),

                          const SizedBox(height: 15),
                          //google and apple sign in buttons
                          // google button
                          Center(
                            child: MyElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AuthService().signInWithGoogle(),
                                  ),
                                );
                              },
                              imagepath: 'lib/images/google.png',
                              buttonText: 'Google',
                            ),
                          ),

                          const SizedBox(height: 15),
                          // apple button
                          Center(
                              child: MyElevatedButton(
                            onPressed: () {},
                            imagepath: 'lib/images/apple.png',
                            buttonText: 'Apple',
                          )),
                        ]),
                  ),
                )
              :
              // Mobile View *************************************
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 10),
                  Text(
                    'Sign Up to Speedyship',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),

                  Row(
                    children: [
                      Text(
                        'Already have an account?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      InkWell(
                        child: Text(
                          'Log in',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  //image picker
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: Colors.grey),
                      ),
                      child: Stack(
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.network(
                                imageUrl,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (imageUrl == null || imageUrl.isEmpty)
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.camera),
                                color: Colors.grey[600],
                                onPressed: () async {
                                  String imageUrl = await uploadImage();
                                  setState(() {
                                    this.imageUrl = imageUrl;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  //Email address
                  MyTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    hintText: 'Email Address',
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 15),
                  //pwd
                  MyTextField(
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    readOnly: false,
                    // validatePassword: true,
                    // validator: Validtor,
                  ),

                  const SizedBox(height: 15),
                  //repeat
                  MyTextField(
                    keyboardType: TextInputType.text,
                    controller: repeatController,
                    hintText: 'Repeat your password',
                    obscureText: true,
                    readOnly: false,
                  ),

                  const SizedBox(height: 15),

                  //firstname
                  MyTextField(
                    keyboardType: TextInputType.text,
                    controller: fnameController,
                    hintText: 'First Name',
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 15),
                  //last name
                  MyTextField(
                    keyboardType: TextInputType.text,
                    controller: lnameController,
                    hintText: 'Last Name',
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 15),
                  //dob
                  MyDatePicker(
                    onDateSelected: (date) => setState(
                      () => _selectedDate = date,
                    ),
                  ),

                  const SizedBox(height: 15),
                  //Phone no
                  MyTextField(
                    keyboardType: TextInputType.number,
                    controller: phonecontroller,
                    hintText: "Phone Number",
                    obscureText: false,
                    readOnly: false,
                  ),

                  const SizedBox(height: 25),
                  //sign in button
                  Center(
                    child: MyButton(
                      onTap: () => signup(),
                      buttonText: 'Sign Up',
                    ),
                  ),
                  const SizedBox(height: 15),
                  //or continue with
                  Row(
                    children: [
                      Expanded(
                        child: const Divider(
                          thickness: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue using',
                        ),
                      ),
                      const Expanded(
                          child: Divider(
                        thickness: 1,
                      ))
                    ],
                  ),
                  const SizedBox(height: 15),
                  //google and apple sign in buttons
                  // google button
                  Center(
                      child: MyElevatedButton(
                    onPressed: () {},
                    imagepath: 'lib/images/google.png',
                    buttonText: 'Google',
                  )),

                  const SizedBox(height: 15),
                  // apple button
                  Center(
                      child: MyElevatedButton(
                    onPressed: () {},
                    imagepath: 'lib/images/apple.png',
                    buttonText: 'Apple',
                  )),
                ]),
        ),
      ),
    );
  }
}

import 'dart:io';

// import 'package:email_validator/email_validator.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speedyship/components/date_picker2.dart';
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
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  //text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final repeatController = TextEditingController();

  final fnameController = TextEditingController();

  final lnameController = TextEditingController();

  final phonecontroller = TextEditingController();

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date.';
    }

    final selectedDate = DateTime.parse(value);
    final currentDate = DateTime.now();

    if (selectedDate.isBefore(currentDate)) {
      return 'Selected date cannot be before today.';
    }

    return null;
  }

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
        'role': 'user',
      });

      // Login a user after they sign up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle sign-up errors here
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ElegantNotification.error(
          title: Text('User Not Found'),
          description: Text('The email you entered does not exist.'),
        ).show(context);
      } else if (e.code == 'network-request-failed') {
        ElegantNotification.error(
          title: Text('Network Error'),
          description: Text(
              'There was a problem with the network connection. Please check your internet connection.'),
        ).show(context);
      }
    } catch (e) {
      print(e);
    }
  }

  // String imageUrl = '';
  String? emailErrorMessage; // Declare a variable to hold the error message

  //rest of the code
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Device.screenType == ScreenType.tablet
              ? Form(
                  key: _formKey,
                  child: Center(
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                InkWell(
                                  child: Text(
                                    'Log in',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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

                            const SizedBox(height: 15),

                            //username

                            MyTextField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              hintText: 'Email',
                              obscureText: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill the email field';
                                } else if (!EmailValidator.validate(value)) {
                                  return 'Invalid email format';
                                }
                                return null; // Return null if the email is valid
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill the password field';
                                } else if (value.length < 8) {
                                  return 'Password must be at least 8 characters long';
                                } else if (!RegExp(r'^(?=.*[a-z])')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least one lowercase letter';
                                } else if (!RegExp(r'^(?=.*[A-Z])')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                } else if (!RegExp(r'^(?=.*\d)')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least one digit';
                                } else if (!RegExp(r'^(?=.*[@$!%*?&])')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least one special character';
                                }
                                return null; // Return null if the password is valid
                              },
                            ),

                            const SizedBox(height: 15),
                            //repeat
                            MyTextField(
                                keyboardType: TextInputType.text,
                                controller: repeatController,
                                hintText: 'Repeat your password',
                                obscureText: true,
                                readOnly: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please fill the repeat password field';
                                  }
                                }),

                            const SizedBox(height: 15),

                            //firstname
                            MyTextField(
                              keyboardType: TextInputType.text,
                              controller: fnameController,
                              hintText: 'first Name',
                              obscureText: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill the first name field';
                                } else if (value.length <= 1) {
                                  return 'Last name must be longer than 1 character';
                                } else if (!RegExp(r'^[a-zA-Z]+$')
                                    .hasMatch(value)) {
                                  return 'Last name must contain only letters';
                                }
                                return null; // Return null if the last name is valid
                              },
                            ),

                            const SizedBox(height: 15),
                            //last name
                            MyTextField(
                              keyboardType: TextInputType.text,
                              controller: lnameController,
                              hintText: 'Last Name',
                              obscureText: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill the last name field';
                                } else if (value.length <= 1) {
                                  return 'Last name must be longer than 1 character';
                                } else if (!RegExp(r'^[a-zA-Z]+$')
                                    .hasMatch(value)) {
                                  return 'Last name must contain only letters';
                                }
                                return null; // Return null if the last name is valid
                              },
                            ),

                            const SizedBox(height: 15),
                            //dob
                            MyDatePickerTwo(
                              onDateSelected: (date) => setState(
                                () => _selectedDate = date,
                              ),
                            ),

                            const SizedBox(height: 15),
                            //Phone no
                            MyTextField(
                              keyboardType: TextInputType.number,
                              controller: phonecontroller,
                              hintText: 'Phone Number',
                              obscureText: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill the phone number field';
                                } else if (!RegExp(r'^\+90[1-9]\d{9}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid Turkish phone number\n(e.g., +905xxxxxxxxx)';
                                }
                                return null; // Return null if the phone number is valid
                              },
                            ),

                            const SizedBox(height: 25),
                            //sign in button
                            Center(
                              child: MyButton(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    signup();
                                  }
                                },
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
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
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

                  const SizedBox(height: 15),

                  //Email address

                  MyTextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    readOnly: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill the email field';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Invalid email format';
                      }
                      return null; // Return null if the email is valid
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill the password field';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      } else if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                        return 'Password must contain at least one lowercase letter';
                      } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain at least one digit';
                      } else if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(value)) {
                        return 'Password must contain at least one special character';
                      }
                      return null; // Return null if the password is valid
                    },
                  ),

                  const SizedBox(height: 15),
                  //repeat
                  MyTextField(
                      keyboardType: TextInputType.text,
                      controller: repeatController,
                      hintText: 'Repeat your password',
                      obscureText: true,
                      readOnly: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill the repeat password field';
                        }
                      }),

                  const SizedBox(height: 15),

                  //firstname
                  MyTextField(
                    keyboardType: TextInputType.text,
                    controller: fnameController,
                    hintText: 'First Name',
                    obscureText: false,
                    readOnly: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill the first name field';
                      } else if (value.length <= 1) {
                        return 'First name must be longer than 1 character';
                      } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                        return 'First name must contain only letters';
                      }
                      return null; // Return null if the first name is valid
                    },
                  ),

                  const SizedBox(height: 15),
                  //last name
                  MyTextField(
                      keyboardType: TextInputType.text,
                      controller: lnameController,
                      hintText: 'Last Name',
                      obscureText: false,
                      readOnly: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill the last name field';
                        }
                      }),

                  const SizedBox(height: 15),
                  //dob
                  MyDatePickerTwo(
                    onDateSelected: (date) => setState(
                      () => _selectedDate = date,
                    ),
                    // lastDate: DateTime(2006, 1,1), // Set the last selectable date to January 1, 2006
                  ),

                  const SizedBox(height: 15),
                  //Phone no
                  MyTextField(
                    keyboardType: TextInputType.number,
                    controller: phonecontroller,
                    hintText: 'Phone Number',
                    obscureText: false,
                    readOnly: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill the phone number field';
                      } else if (!RegExp(r'^\+90[1-9]\d{9}$').hasMatch(value)) {
                        return 'Please enter a valid Turkish phone number\n(e.g., +905xxxxxxxxx)';
                      }
                      return null; // Return null if the phone number is valid
                    },
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

import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:speedyship/components/my_textfield.dart';
import 'package:speedyship/components/square_tile.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:speedyship/pages/introduction/ForgotPassword.dart';
import 'package:speedyship/services/auth_service.dart';
import 'signup.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:speedyship/components/my_elevated_button.dart';
import 'package:email_validator/email_validator.dart';
import 'package:elegant_notification/elegant_notification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //form key
  final _formKey = GlobalKey<FormState>();
  //text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign in a user
  Future signin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ElegantNotification.error(
          title: Text('User Not Found'),
          description: Text('The email you entered does not exist.'),
          animation: AnimationType.fromTop,
          notificationPosition: NotificationPosition.topCenter,
        ).show(context);
      } else if (e.code == 'wrong-password') {
        ElegantNotification.error(
          title: Text('Invalid Password'),
          description: Text('The password you entered is incorrect.'),
          animation: AnimationType.fromTop,
          notificationPosition: NotificationPosition.topCenter,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Device.screenType == ScreenType.tablet
                ?
                // desktop View*********************************************************
                Center(
                    child: SizedBox(
                      width: 40.w,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),

                            //Signin text
                            Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),

                            const SizedBox(
                              height: 15.0,
                            ),

                            const SizedBox(height: 15),

                            // no acccount & add account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // no account text
                                const Text('No account?'),

                                //make account tap
                                InkWell(
                                    child: Text(
                                      'Make account',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignupPage()));
                                    }),
                              ],
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            //Email input

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

                            //Password
                            MyTextField(
                              keyboardType: TextInputType.text,
                              controller: passwordController,
                              hintText: 'password',
                              obscureText: true,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill the password field";
                                }
                              },
                            ),

                            const SizedBox(height: 15),

                            //forgot pwd?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPasswordPage()));
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),
                            //sign in button
                            Center(
                                child: MyButton(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  print("You Logged in successfully");
                                  signin();
                                }
                              },
                              buttonText: 'Sign in',
                            )),
                            const SizedBox(height: 15),

                            //or continue using
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: const Divider(
                            //         thickness: 1,
                            //       ),
                            //     ),
                            //     const Padding(
                            //       padding:
                            //           EdgeInsets.symmetric(horizontal: 10.0),
                            //       child: Text(
                            //         'Or continue using',
                            //       ),
                            //     ),
                            //     const Expanded(
                            //         child: Divider(
                            //       thickness: 1,
                            //     ))
                            //   ],
                            // ),

                            const SizedBox(height: 15),

                            // google button
                            // Center(
                            //     child: MyElevatedButton(
                            //   onPressed: () {
                            //     print("hello google is pressed");
                            //     AuthService().signInWithGoogle();
                            //   },
                            //   imagepath: 'lib/images/google.png',
                            //   buttonText: 'Google',
                            // )),

                            const SizedBox(height: 15),
                            // apple button
                            // Center(
                            //     child: MyElevatedButton(
                            //   onPressed: () {},
                            //   imagepath: 'lib/images/apple.png',
                            //   buttonText: 'Apple',
                            // )),
                          ]),
                    ),
                  )
                :
                //Mobile view************************************************************
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 50),

                    //Signin text
                    Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),

                    const SizedBox(
                      height: 15.0,
                    ),

                    const SizedBox(height: 15),

                    // no acccount & add account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // no account text
                        const Text('No account?'),

                        //make account tap
                        InkWell(
                            child: Text(
                              'Make account',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    //Email input

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

                    //Password
                    MyTextField(
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      readOnly: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please fill the email field";
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    //forgot pwd?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordPage()));
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    //sign in button
                    Center(
                        child: MyButton(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          signin();
                        }
                      },
                      buttonText: 'Sign in',
                    )),
                    const SizedBox(height: 15),

                    //or continue using
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: const Divider(
                    //         thickness: 1,
                    //       ),
                    //     ),
                    //     const Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10.0),
                    //       child: Text(
                    //         'Or continue using',
                    //       ),
                    //     ),
                    //     const Expanded(
                    //         child: Divider(
                    //       thickness: 1,
                    //     ))
                    //   ],
                    // ),

                    const SizedBox(height: 15),

                    // google button
                    // Center(
                    //     child: MyElevatedButton(
                    //   onPressed: () {
                    //     print("hello google is pressed");

                    //     AuthService().signInWithGoogle();
                    //   },
                    //   imagepath: 'lib/images/google.png',
                    //   buttonText: 'Google',
                    // )),

                    const SizedBox(height: 15),
                    // // apple button
                    // Center(
                    //     child: MyElevatedButton(
                    //   onPressed: () {},
                    //   imagepath: 'lib/images/apple.png',
                    //   buttonText: 'Apple',
                    // )),
                  ]),
          ),
        ),
      ),
    );
  }
}

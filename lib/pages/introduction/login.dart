import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:speedyship/components/my_textfield.dart';
import 'package:speedyship/components/square_tile.dart';
import 'package:speedyship/components/my_button.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign in a user
  Future signin() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
  }

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
                'Welcome back!',
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
              //forgot pwd?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              //sign in button
              MyButton(onTap: () => signin()),
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
                    'Not a member?',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupPage()));
                    },
                    child: Text(
                      'Register now',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

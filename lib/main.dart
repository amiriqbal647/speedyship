import 'package:flutter/material.dart';
import 'package:speedyship/pages/introduction/login.dart';
import 'package:speedyship/pages/introduction/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:speedyship/pages/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

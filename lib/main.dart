import 'package:flutter/material.dart';
import 'package:speedyship/pages/introduction/login.dart';
import 'package:speedyship/pages/introduction/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:speedyship/pages/auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        theme:
            FlexThemeData.light(scheme: FlexScheme.tealM3, useMaterial3: true),
        darkTheme:
            FlexThemeData.dark(scheme: FlexScheme.tealM3, useMaterial3: true),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
      );
    });
  }
}

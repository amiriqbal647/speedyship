import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:speedyship/pages/introduction/login.dart';
import 'package:speedyship/pages/user/user_main_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  signInWithGoogle() async {
    if (kIsWeb) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      throw Exception('signInWithGoogle is only supported on the web.');
    }
  }
}

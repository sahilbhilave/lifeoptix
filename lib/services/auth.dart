import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/authenticate/sign_in.dart';
import 'package:prototype/screens/home/home.dart';
import 'package:prototype/screens/inputdata/checkdata.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const CheckData();
        } else {
          return SignIn();
        }
      },
    ));
  }
}

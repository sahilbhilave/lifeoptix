import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prototype/firebase_options.dart';
import 'package:prototype/screens/authenticate/sign_in.dart';
import 'package:prototype/screens/wrapper.dart';
import 'package:prototype/services/auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthPage());
  }
}

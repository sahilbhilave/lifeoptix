import 'package:flutter/material.dart';
import 'package:prototype/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return either home or authenticate
    return Home();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype/screens/home/home.dart';
import 'package:prototype/screens/home/main.dart';

class InfoPage extends StatelessWidget {
  final bool isAdmin;
  final List<String> conditions;
  final String name;
  final int age;
  final String fitnessGoal;

  InfoPage({
    required this.isAdmin,
    required this.conditions,
    required this.name,
    required this.age,
    required this.fitnessGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InfoPage'),
        backgroundColor: Color.fromARGB(255, 22, 26, 48),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color.fromARGB(255, 22, 26, 48),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'What Now?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: const Text(
                'This app will help you keep track of 5 aspects of your life that is health, fitness, mind, social, work \n\nYou will be assigned points based on the tasks you do on this app \n\nYour goal is to maintain a high health score.\n*A high Health Score means a balanced and healthy lifestyle! \n\nGood Luck!! ',
                style: TextStyle(fontSize: 16, color: Colors.white),
                //textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                // Get the current user
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  // Add user data to Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .set({
                    'email': user.email,
                    'isAdmin': isAdmin,
                    'conditions': conditions,
                    'name': name,
                    'age': age,
                    'fitnessGoal': fitnessGoal,
                    'healthScore': 0,
                    'points': {
                      'nutrition': 0,
                      'fitness': 0,
                      'mind': 0,
                      'social': 0,
                      'work': 0
                    },
                    'equipments': [],
                    'tasks': {'values': []}
                  });
                  // Navigate to the home page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Main()),
                  );
                } else {
                  // Handle the case where the user is not logged in
                  print('User is not logged in');
                }
              },
              child: Text('Let\'s Begin'),
            ),
          ],
        ),
      ),
    );
  }
}

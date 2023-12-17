import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/admin/adminpage.dart';
import 'package:prototype/screens/authenticate/sign_in.dart';
import 'package:prototype/screens/home/home.dart';
import 'package:prototype/screens/home/main.dart';
import 'package:prototype/screens/inputdata/inputdata.dart';

class CheckData extends StatelessWidget {
  const CheckData({Key? key});

  Future<bool> checkIfEmailExists(String? email) async {
    // Reference to the Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      QuerySnapshot querySnapshot =
          await users.where('email', isEqualTo: email).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  Future<bool> checkAdminStatus() async {
    bool isAdmin = false;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user?.uid)
          .get();

      isAdmin = userDoc['isAdmin'] ?? false;
      return isAdmin;
    } catch (e) {
      print("Error fetching admin status: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking authentication state
            return CircularProgressIndicator();
          }

          User? user = snapshot.data;

          if (user != null) {
            // User is signed in, check if email exists
            checkIfEmailExists(user.email).then((exists) async {
              if (exists) {
                if (await checkAdminStatus()) {
                  // User is an admin, navigate to AdminPage
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AdminApp()),
                  );
                } else {
                  // User is not an admin, navigate to Main
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Main()),
                  );
                }
              } else {
                // Email does not exist, navigate to SignIn screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                );
              }
            });
          } else {
            // User is not signed in, navigate to SignIn screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignIn()),
            );
          }

          // Return an empty container as a placeholder
          return Container();
        },
      ),
    );
  }
}

class AdminPage {}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype/screens/admin/adminhome.dart';
import 'package:prototype/screens/admin/adminwork.dart';
import 'package:prototype/screens/home/exercise/fitness.dart';
import 'package:prototype/screens/home/exercise/heart.dart';
import 'package:prototype/screens/home/home.dart';
import 'package:prototype/services/auth.dart';

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthChecker(),
    );
  }
}

bool isAdmin = false;

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while checking authentication state
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final isSignedIn = snapshot.hasData;

          return isSignedIn ? MyHomePage() : AuthPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [AdminHome(), AdminWork()],
      ),
      bottomNavigationBar: FirebaseAuth.instance.currentUser != null
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: Colors.black,
                  icon: Icon(
                    Icons.find_in_page,
                  ),
                  label: 'Find',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.data_array),
                  label: 'Data',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_heart),
                  label: 'Heart',
                )
              ],
            )
          : null, // Set to null to hide the bottom navigation bar
    );
  }
}

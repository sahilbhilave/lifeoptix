import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prototype/services/auth.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedEmail = "";
  String _selectedName = "";
  int _selectedAge = 0;

  Future<void> searchUsers(String searchText) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: searchText)
        .where('email', isLessThan: searchText + 'z')
        .limit(10)
        .get();

    if (result.docs.isNotEmpty) {
      final userData = result.docs[0].data() as Map<String, dynamic>?;

      setState(() {
        _selectedEmail = userData?['email'] ?? "";
        _selectedName = userData?['name'] ?? "";
        _selectedAge = userData?['age'] as int? ?? 0;
      });
    }
  }

  Future<void> sendRequest() async {
    if (_selectedEmail.isNotEmpty) {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        String senderEmail = userDoc['email'] ?? "";
        String senderName = userDoc['name'] ?? "";
        int senderAge = userDoc['age'] ?? 0;

        // Check if the request already exists
        final QuerySnapshot existingRequests = await FirebaseFirestore.instance
            .collection('requests')
            .where('senderemail', isEqualTo: senderEmail)
            .where('to', isEqualTo: _selectedEmail)
            .get();

        final QuerySnapshot existingFollower = await FirebaseFirestore.instance
            .collection('follow')
            .where('from', isEqualTo: senderEmail)
            .where('to', isEqualTo: _selectedEmail)
            .get();

        if (existingRequests.docs.isEmpty && existingFollower.docs.isEmpty) {
          // If the request does not exist, add it to Firestore
          await FirebaseFirestore.instance.collection('requests').add({
            'sendername': senderName,
            'senderemail': senderEmail,
            'senderAge': senderAge,
            'to': _selectedEmail,
          });

          // Get today's date
          final DateTime now = DateTime.now();
          final String todayDate = '${now.year}-${now.month}-${now.day}';

          // Store the request information in the 'requests' collection
          await FirebaseFirestore.instance.collection('requests').add({
            'from': _selectedName,
            'to': _selectedEmail,
            'date': todayDate,
          });
        } else {
          if (!existingRequests.docs.isEmpty) {
            // Request already exists, you can handle this case accordingly
            String message = "Request already sent!!";

            // Colorful Text
            Text colorfulText = Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );

            final snackBar = SnackBar(
              content: colorfulText,
              duration: Duration(seconds: 2),
            );

            // Show SnackBar at the top center
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print('Request already exists');
          } else if (!existingFollower.docs.isEmpty) {
            // Request already exists, you can handle this case accordingly
            String message = "Already following!!";

            // Colorful Text
            Text colorfulText = Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );

            final snackBar = SnackBar(
              content: colorfulText,
              duration: Duration(seconds: 2),
            );

            // Show SnackBar at the top center
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            print('Already Following');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        actions: [
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Find Members",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 25,
            ),
            // Search Input Field with Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Call the function to search for users
                  searchUsers(value);
                },
                decoration: InputDecoration(
                  labelText: 'Search by ID',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _selectedEmail = "";
                      });
                    },
                  ),
                ),
              ),
            ),

            // Display Dropdown Search Result
            if (_selectedEmail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Email: $_selectedEmail'),
                    if (_selectedName.isNotEmpty) Text('Name: $_selectedName'),
                    Text('Age: $_selectedAge'),
                  ],
                ),
              ),
            SizedBox(
              height: 25,
            ),
            // Button to Send a Request
            ElevatedButton(
              onPressed: () {
                sendRequest();
              },
              child: Text('Send a Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const AuthPage(), // Replace with your initial route
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}

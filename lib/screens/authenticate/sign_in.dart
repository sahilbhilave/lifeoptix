import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/authenticate/register.dart';
import 'package:prototype/screens/inputdata/checkdata.dart';

void main() {
  runApp(SignIn());
}

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String usernameError = '';
  String passwordError = '';
  String authStatus = '';
  bool isLoading = false; // Added to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 6, 31, 44),
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "LifeOptiX",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Your first step towards progress ",
                  style: TextStyle(
                    color: Colors.lightGreen,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Log In To Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: TextField(
                    controller: usernameController,
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        authStatus = "";
                        usernameError =
                            isValidUsername(value) ? '' : 'Enter Proper Email';
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorText:
                          usernameError.isNotEmpty ? usernameError : null,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 15.0), // Adjust the padding as needed
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        authStatus = "";
                        passwordError = isValidPassword(value)
                            ? ''
                            : 'Min 6 Character Password';
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        errorText:
                            passwordError.isNotEmpty ? passwordError : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 15.0)),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  authStatus,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    // Validate username and password
                    if (!isValidUsername(usernameController.text)) {
                      setState(() {
                        usernameError = 'Enter Proper Email';
                      });
                    } else {
                      setState(() {
                        usernameError = '';
                      });
                    }

                    if (!isValidPassword(passwordController.text)) {
                      setState(() {
                        passwordError = 'Min 6 Character Password';
                      });
                    } else {
                      setState(() {
                        passwordError = '';
                      });
                    }

                    if (usernameError.isEmpty && passwordError.isEmpty) {
                      setState(() {
                        isLoading = true; // Set loading to true
                      });

                      String email = usernameController.text;
                      String password = passwordController.text;

                      try {
                        // Sign in with Firebase
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);

                        // Update authentication status
                        setState(() {
                          //authStatus = 'User is present';
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => CheckData()),
                          );
                        });
                      } catch (e) {
                        // Handle authentication errors
                        print("RERADFDSFS : $e ");
                        setState(() {
                          String status = e.toString();

                          authStatus = "Email or Password is Wrong!!";
                        });
                        print('Error: $e');
                      } finally {
                        setState(() {
                          isLoading = false; // Set loading to false
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1B4242),
                    onPrimary: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: isLoading
                        ? CircularProgressIndicator() // Show loading indicator
                        : Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1B4242),
                    onPrimary: Colors.white,
                    padding: EdgeInsets.all(20),
                  ),
                  icon: Image.asset('assets/google_logo.webp', height: 30),
                  label: Text('Login using Google',
                      style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  child: const Text(
                    "Don't Have an Account? SIGNUP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Handle reset password click
                  },
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Registerp(),
      transitionDuration:
          Duration(milliseconds: 1000), // Adjust the duration here
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOutQuart;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  bool isValidUsername(String username) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(username);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}

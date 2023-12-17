import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prototype/screens/authenticate/sign_in.dart';

class Registerp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String usernameError = '';
  String passwordError = '';
  String repasswordError = '';
  String authStatus = '';
  bool isLoading = false; // Added to track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 8, 43, 22),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
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
                    "Register using email",
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
                          usernameError = isValidUsername(value)
                              ? ''
                              : 'Enter Proper Email';
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
                            vertical: 15.0, horizontal: 15.0),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          authStatus = "";
                          passwordError = isValidPassword(value)
                              ? ''
                              : 'Enter 6 Character Password';
                        });
                      },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: TextField(
                      controller: rePasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          authStatus = "";
                          repasswordError = isSimilarPassword(value)
                              ? ''
                              : 'Passwords do not match';
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Re-enter Password',
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorText: repasswordError.isNotEmpty
                              ? repasswordError
                              : null,
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
                          passwordError = 'Enter proper Password';
                        });
                      } else if (passwordController.text !=
                          rePasswordController.text) {
                        setState(() {
                          repasswordError = 'Passwords do not match';
                        });
                      } else {
                        setState(() {
                          passwordError = '';
                          repasswordError = '';
                          isLoading = true; // Set loading state to true
                        });

                        if (isValidPassword(passwordController.text)) {
                          passwordError = '';
                        }
                      }

                      if (usernameError.isEmpty &&
                          passwordError.isEmpty &&
                          repasswordError.isEmpty) {
                        String email = usernameController.text;
                        String password = passwordController.text;

                        try {
                          // Register with Firebase
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);

                          setState(() {
                            authStatus = 'User is present';
                            print("YEASADa");
                          });
                        } catch (e) {
                          print("RERADFDSFS : $e ");
                          setState(() {
                            String status = e.toString();

                            authStatus = "Email already exists!!";
                          });
                          print('Error: $e');
                        } finally {
                          setState(() {
                            isLoading = false; // Set loading state to false
                          });
                        }
                        print("Username: $email");
                        print("Password: $password");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF1B4242),
                      onPrimary: Colors.white,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: isLoading
                          ? CircularProgressIndicator() // Show loading indicator
                          : Text(
                              'Register',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(_createRoute());
                    },
                    child: const Text(
                      "Go back to Login?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(_createRoute());
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignIn(),
      transitionDuration: Duration(milliseconds: 1000),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
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

  bool isSimilarPassword(String password) {
    return (passwordController.text == rePasswordController.text);
  }
}

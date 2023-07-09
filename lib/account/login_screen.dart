import 'package:flutter/material.dart';
import 'package:travel_buddy/account/signup_screeen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_buddy/constant/colors.dart';
import 'package:travel_buddy/constant/fonts.dart';
import 'package:travel_buddy/main.dart';

import '../business/navigation.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<UserCredential?> _loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      displayMessage('No Record Found');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          'Login',
          style: appbar,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "images/logo.jpg",
                height: 80,
                width: 80,
              ),
              SizedBox(height: 25),
              Text('Welcome to MyApp', style: appbar),
              SizedBox(height: 40),
              Container(
                height: 60,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintStyle: textFireld,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                height: 60,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintStyle: textFireld,
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 40),
                  // Disable the button when loading
                  primary: _isLoading ? Colors.grey : null,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                  final email = _emailController.text;
                  final password = _passwordController.text;

                  if (email.isEmpty) {
                    displayMessage("Please enter the email");
                  } else if (password.isEmpty) {
                    displayMessage("Please enter the password");
                  } else {
                    setState(() {
                      _isLoading = true; // Show progress indicator
                    });

                    final userCredential = await _loginWithEmailAndPassword(email, password);

                    setState(() {
                      _isLoading = false; // Hide progress indicator
                    });

                    if (userCredential != null) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => BottomNavigationBarExample()),
                      );
                    }
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator() // Show progress indicator
                    : Text(
                  'Login',
                  style: buttonText,
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => SignupPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

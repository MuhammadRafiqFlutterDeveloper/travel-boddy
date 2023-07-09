import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_buddy/account/login_screen.dart';
import 'package:travel_buddy/constant/colors.dart';
import 'package:travel_buddy/constant/fonts.dart';
import '../business/navigation.dart';
import '../main.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool obscureText = true;

  File? selectedImage;
  var base64Image = "";
  Position? _currentPositio;

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPositio = position;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> chooseImage(type) async {
    var image;
    if (type == "camera") {
      image = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
    } else {
      image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
    }
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
        // won't have any error now
      });
    }
  }

  Future<void> _choiseShowDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Select Image From",
              style: appbar,
            ),
            actions: [
              GestureDetector(
                child: Text(
                  "Gallery",
                  style: buttonText,
                ),
                onTap: () {
                  chooseImage("Gallery");
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: GestureDetector(
                  child: Text(
                    "camera",
                    style: buttonText,
                  ),
                  onTap: () {
                    chooseImage(
                      "camera",
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Signup',
          style: appbar,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Let’s Get It Started!",
                    style: appbar,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 115,
                  width: 100,
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: selectedImage == null
                              ? AssetImage('images/logo.jpg') as ImageProvider
                              : FileImage(selectedImage!),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                            onPressed: () {
                              _choiseShowDialog(context);
                            },
                            icon: Icon(
                              Icons.camera,
                              color: green,
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  child: TextFormField(
                    // cursorColor: buttonColor,
                    controller: fullNameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 10,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Full Name',
                      hintStyle: textFireld,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Full Name Required";
                      } else
                        return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        left: 10,
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                      hintStyle: textFireld,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Email Required";
                      } else
                        return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password', hintStyle: textFireld,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        child: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: green,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(
                          left: 15, top: 15, right: 15, bottom: 15),
                      alignLabelWithHint: true,
                      // labelStyle: TextStyle(color: Colors.blue),
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width, 40)),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (selectedImage == null) {
                            displayMessage('Please Select Image');
                          } else if (fullNameController.text.isEmpty) {
                            displayMessage("Full Name Required");
                          } else if (emailController.text.isEmpty) {
                            displayMessage("Email required");
                          } else if (passwordController.text.isEmpty) {
                            displayMessage("Password Required");
                          } else if (passwordController.text.length < 6) {
                            displayMessage(
                                'password and confirmPassword should be AtLeast 6 Character');
                          } else {
                            createUser();
                          }
                        },
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          "SignUp",
                          style: buttonText,
                        ),
                ),
                SizedBox(
                  height: 50,
                ),
                RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          },
                        text: "Login",
                        style: buttonText,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var fullNameController = TextEditingController();
  var _isLoading = false;
  Future<String> testFuture() async {
    await Future.delayed(Duration(seconds: 5));
    return "response";
  }

  Future<void> createUser() async {
    try {
      setState(() {
        _isLoading = true;
      });
      double latitude = _currentPositio?.latitude ?? 0.0;
      double longitude = _currentPositio?.longitude ?? 0.0;

      if (latitude == 0.0 || longitude == 0.0) {
        // Unable to fetch location
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String myEmail = emailController.text;
      String password = passwordController.text;

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: myEmail, password: password);

      User? user = userCredential.user;
      final _uid = user!.uid;

      final ref = FirebaseStorage.instance
          .ref()
          .child('userImages')
          .child(_uid + '.jpg');
      await ref.putFile(selectedImage!);
      base64Image = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {
          'uid': _uid,
          'name': fullNameController.text,
          'email': myEmail,
          'password': password,
          'currentDate': DateTime.now(),
          'profile': base64Image,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationBarExample()),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      displayMessage(error.toString());
    }
  }
}

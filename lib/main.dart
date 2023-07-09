import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'account/login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'business/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

displayMessage(String Message) {
  Fluttertoast.showToast(
    msg: Message,
    toastLength: Toast.LENGTH_LONG,
    timeInSecForIosWeb: 2,
  );
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      // Replace 'NextScreen()' with the widget you want to navigate to
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) =>
            // FirebaseAuth.instance.currentUser != null
            //     ?
                BottomNavigationBarExample()
            //     :
            // LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Customize the background color here
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/logo.jpg",
                height: 140,
                width: 140,
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

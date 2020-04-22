import 'package:flutter/material.dart';
import 'screens/MainScreen.dart';
import 'screens/SplashScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mawjood',
      theme: ThemeData(
        primaryColor: Colors.white,
        //primarySwatch: Colors.white,
        textTheme: TextTheme(
          display4: TextStyle(
            fontFamily: 'Corben',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      home: Loader(),
    );
  }
}


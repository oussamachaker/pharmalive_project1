import 'package:flutter/material.dart';
import 'screens/MyMapPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mawjood',
      theme: ThemeData(
        // "flutter run"
        primarySwatch: Colors.green,
      ),
      home: MyMapPage(title: 'Map Mawjood'),
    );
  }
}


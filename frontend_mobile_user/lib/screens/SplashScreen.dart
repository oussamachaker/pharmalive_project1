import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend_mobile_user/screens/MainScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:splashscreen/splashscreen.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Loader extends StatefulWidget {
  @override
  _LoaderState createState() => new _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 3,
      navigateAfterSeconds: MainScreen(title: "Mawjood"),
      image: new Image.asset('assets/images/Logo.png'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 150.0,
      onClick: () => print("Flutter loader"),
      loaderColor: Colors.black,
    ) ;
  }
}
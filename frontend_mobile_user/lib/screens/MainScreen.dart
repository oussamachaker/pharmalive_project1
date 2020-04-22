import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:splashscreen/splashscreen.dart';
import '../json_serializable/locations.dart' as locations;

class MainScreen extends StatefulWidget {
  MainScreen ({Key key, this.title}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.
  final String title;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen > {
  bool _mainScreen = true;
  GoogleMapController _mapController ;
  final Map<String, Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinPharmaIcon;
  LatLng myPinPosition;
  Geolocator _geolocator;
  Position _position;
  CameraPosition initialLocation;
  GoogleMap googleMap;

  @override
  void initState() {
    super.initState();
    print("-----------------------------------InitState");
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/myLocationIcon.png').then((onValue) {
      pinLocationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/pharmaIcon.png').then((onValue) {
      pinPharmaIcon = onValue;
    });
    _geolocator = Geolocator();
    checkPermission();
    updateLocation();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    final googleDrugStores = await locations.getGoogleDrugStores();
    setState(() {
      _markers.clear();
      final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition ,
          icon: pinLocationIcon
      );
      _markers["I am here"] = myMarker;

      for (final drugStore in googleDrugStores.drugStores) {
        final marker = Marker(
          markerId: MarkerId(drugStore.name),
          position: LatLng(drugStore.lat, drugStore.lng),
          icon: pinPharmaIcon,
          infoWindow: InfoWindow(
            title: drugStore.name,
            snippet: "Nb Masks : " + drugStore.numberFaceMask.toString(),
          ),
        );
        _markers[drugStore.name] = marker;
      }
    });

  }

  void centerOverLocation(){
    setState(() {
      print("--------------- center over current location");
      _mapController.moveCamera(CameraUpdate.newLatLng(myPinPosition));
      _markers.removeWhere((key, value) => key == "I am here");
      final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition ,
          icon: pinLocationIcon
      );
      _markers["I am here"] = myMarker;
    });
  }

  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) { print('status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationAlways).then((status) { print('always status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse)..then((status) { print('whenInUse status: $status'); });
  }

  void updateMarkers() async {
    print("---------------- update marker on camera move end");
    LatLngBounds latLngBounds = await _mapController.getVisibleRegion();
    print("++++++++ NW lat : " +  latLngBounds.northeast.latitude.toString() + " ----" + latLngBounds.northeast.longitude.toString() );
    print("++++++++ NW lat : " +  latLngBounds.southwest.latitude.toString() + " ----" + latLngBounds.southwest.longitude.toString() );
  }

  void updateLocation() async {

    print("---------------- getting user's location");
    try {
      Position newPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 20));
      setState(() {
        _position = newPosition;
        myPinPosition = LatLng(_position.latitude , _position.longitude);
        initialLocation= CameraPosition(
            zoom: 16,
            bearing: 30,
            target: LatLng(_position.latitude , _position.longitude)
        );
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_position != null) {
      googleMap = GoogleMap(
          compassEnabled: false,
          indoorViewEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          mapToolbarEnabled: false,
          initialCameraPosition: initialLocation,
          onMapCreated: _onMapCreated,
          markers: _markers.values.toSet(),
          onCameraIdle: updateMarkers,
          gestureRecognizers: Set()
            ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
      );
    }
    return Scaffold(
      appBar: _mainScreen ? PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                  color: Colors.white70,
                  spreadRadius: 7,
                  blurRadius: 5
              )]
          ),
          width: MediaQuery.of(context).size.width,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.navigate_before, color: Colors.transparent),
                  Text("M A W J O O D",style: TextStyle(fontSize: 20, color: Colors.black)),
                  Icon(Icons.navigate_before, color: Colors.transparent),
                ],
              ),
            ),
          ),
        ),
      ) : null ,

      body: (_position != null) ? googleMap
          : SpinKitDoubleBounce(color: Colors.black),


      floatingActionButton: Stack(
        children: <Widget>[
          (_mainScreen == false) ? Align(
            alignment: FractionalOffset(0.1, 0.1),
            child: FloatingActionButton(
              elevation: 4.0,
              child: const Icon(Icons.arrow_back_ios, color: Colors.black ),
              backgroundColor: Colors.white,
              onPressed: () {
                _mainScreen = true;
              },
            ) ,
          ) : Align(),

          _mainScreen ? Align(
            alignment: FractionalOffset(0.5, 0.96),
            child: FloatingActionButton.extended(
              elevation: 4.0,
              icon: const Icon(Icons.location_searching, color: Colors.black ),
              label: const Text('Locate Me',style: TextStyle(fontSize: 15, fontFamily: 'Corben', color: Colors.black) ),
              backgroundColor: Colors.yellow,
              onPressed: () {
                centerOverLocation();
              },
            ) ,
          ) : Align(),
        ],
      ),

        floatingActionButtonLocation: _mainScreen ?
          FloatingActionButtonLocation.centerDocked : null,

      bottomNavigationBar: _mainScreen ? BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.fullscreen),
                onPressed: () {
                  _mainScreen = false;
                },
              )
            ],
          ),
        ): null
    );
  }
}



/*

                      children: <Widget>[
                        Image.asset(
                          "assets/images/background.png",
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right: 13.0),
                          child: Container(
                            height: kToolbarHeight,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "M A W J O O D",
                                    style: TextStyle(
                                      fontFamily: 'Corben',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    controller.animateTo(-appBarHeight,
                                        duration: Duration(seconds: 4),
                                        curve: Curves.fastOutSlowIn);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.location_searching,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

 */
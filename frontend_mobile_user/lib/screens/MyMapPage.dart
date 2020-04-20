import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../json_serializable/locations.dart' as locations;

class MyMapPage extends StatefulWidget {
  MyMapPage({Key key}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.

  void updateState() {
    _MyMapPageState().updateLocation();
  }

  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {

  Completer<GoogleMapController> _controller = Completer();
  final Map<String, Marker> _markers = {};

  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinPharmaIcon;

  LatLng myPinPosition;
  Geolocator _geolocator;
  Position _position;
  CameraPosition initialLocation;

  @override
  void initState() {
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
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
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

  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) { print('status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationAlways).then((status) { print('always status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse)..then((status) { print('whenInUse status: $status'); });
  }

  Future updateLocation() async {

    print("----------------took old location");
    try {
      Position newPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 20));
      if (newPosition == null) {
        newPosition = await Geolocator().getLastKnownPosition();
      }
      setState(() {
        _position = newPosition;
        myPinPosition = LatLng(_position.latitude , _position.longitude);
        initialLocation= CameraPosition(
            zoom: 16,
            bearing: 30,
            target: myPinPosition
        );
      return 200;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {

    initialLocation= CameraPosition(
        zoom: 16,
        bearing: 30,
        target: myPinPosition
    );
    return  GoogleMap(
        compassEnabled : false, indoorViewEnabled: false, myLocationButtonEnabled: false, myLocationEnabled: false, mapToolbarEnabled: false,
        initialCameraPosition: initialLocation,
        onMapCreated: _onMapCreated,
        markers: _markers.values.toSet(),
        gestureRecognizers: Set()..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
    );
  }

}
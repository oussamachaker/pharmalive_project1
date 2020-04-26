import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../json_serializable/locations.dart' as locations;
import 'SearchScreen.dart';

class MainScreen extends StatefulWidget {
  MainScreen ({Key key, this.title}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.
  final String title;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinPharmaIcon;

  bool _mainScreen = true;
  GoogleMapController _mapController ;
  final Map<String, Marker> _markers = {};

  LatLng myPinPosition;
  Geolocator _geolocator;
  Position _position;
  CameraPosition initialLocation;

  @override
  void initState() {
    super.initState();
    print("----------------------------------- Init State");
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
    _mapController = controller;
    updateLocation();

    final googleDrugStores = await locations.getGoogleDrugStores();
    setState(() {
      _markers.clear();
      for (final drugStore in googleDrugStores.drugStores) {
        final marker = Marker(
          markerId: MarkerId(drugStore.id),
          position: LatLng(drugStore.lat, drugStore.lng),
          icon: pinPharmaIcon,
          infoWindow: InfoWindow(
            title: drugStore.name,
            snippet: "Nb Masks : " + drugStore.numberFaceMask.toString(),
          ),
        );
        _markers[drugStore.id] = marker;
      }
      if (myPinPosition != null) {
        final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition,
          icon: pinLocationIcon,
          infoWindow: InfoWindow(
              title: "My Location"
          ),
        );
        _markers["MyLocation"] = myMarker;
      }
    });
  }

  void centerOverLocation(){
    print("--------------- center over current location");
    _markers.removeWhere((key, value) => key == "MyLocation");
    final myMarker = Marker(
        markerId: MarkerId("MyLocation"),
        position: myPinPosition ,
        icon: pinLocationIcon
    );
    setState(() {
      _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: myPinPosition, zoom: 16, tilt: 30),
          )
      );
      _markers["MyLocation"] = myMarker;
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
    double NElat = latLngBounds.northeast.latitude;
    double NElng = latLngBounds.northeast.longitude;
    double SWlat = latLngBounds.southwest.latitude;
    double SWlng = latLngBounds.southwest.longitude;
    final getDrugStores = await locations.getGoogleDrugStores();
    setState(() {
      _markers.clear();
      for (final drugStore in getDrugStores.drugStores) {
        if(drugStore.lat<NElat && drugStore.lng<NElng && drugStore.lat>SWlat && drugStore.lng>SWlng ) {
          final marker = Marker(
            markerId: MarkerId(drugStore.id),
            position: LatLng(drugStore.lat, drugStore.lng),
            icon: pinPharmaIcon,
            infoWindow: InfoWindow(
              title: drugStore.name,
              snippet: "Nb Masks : " + drugStore.numberFaceMask.toString(),
            ),
          );
          _markers[drugStore.id] = marker;
        }
      }
      if (myPinPosition != null) {
        final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition,
          icon: pinLocationIcon,
          infoWindow: InfoWindow(
              title: "My Location"
          ),
        );
        _markers["MyLocation"] = myMarker;
      }
    });
  }

  void updateLocation() async {

    print("---------------- update location");
    try {
      Position newPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 20));
      setState(() {
        _position = newPosition;
        myPinPosition = LatLng(_position.latitude , _position.longitude);
        _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: myPinPosition, zoom: 16,tilt: 30),
            )
        );
        final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition ,
          icon: pinLocationIcon,
          infoWindow: InfoWindow(
              title: "My Location"
          ),
        );
        _markers["MyLocation"] = myMarker;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context) async {

    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(),
        ));

    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
      LatLng returnedValue = result;
      returnedValue = (returnedValue == null)? myPinPosition: returnedValue;
      _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: returnedValue, zoom: 16,tilt: 30),
          )
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _mainScreen ? PreferredSize(
        preferredSize: Size(double.infinity, 70),
        child: Container(
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(
                  color: Colors.white70,
                  spreadRadius: 8,
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
              margin: EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.navigate_before, color: Colors.transparent),
                  Text("M A W J O O D",style: TextStyle(fontSize: 21, color: Colors.black)),
                  Icon(Icons.navigate_before, color: Colors.transparent),
                ],
              ),
            ),
          ),
        ),
      ) : null,

      body: GoogleMap(
          compassEnabled : false, indoorViewEnabled: false, myLocationButtonEnabled: false, myLocationEnabled: false, mapToolbarEnabled: false,
          initialCameraPosition: CameraPosition(
              tilt: 90,
              zoom: 6.83,
              target: LatLng(33.7931605 , 9.5607653)
          ),
          onMapCreated: _onMapCreated,
          markers: _markers.values.toSet(),
          onCameraIdle: updateMarkers,
          gestureRecognizers: Set()..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
        ),

      floatingActionButton: Stack(
        children: <Widget>[
          (_mainScreen == false) ? Align(
            alignment: FractionalOffset(0.12, 0.12),
            child: FloatingActionButton(
              elevation: 4.0,
              child: const Icon(Icons.arrow_back_ios, color: Colors.black ),
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _mainScreen = true;
                });
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
                onPressed: () {
                  _awaitReturnValueFromSecondScreen(context);
                },
              ),
              IconButton(
                icon: Icon(Icons.fullscreen),
                onPressed: () {
                  setState(() {
                    _mainScreen = false;
                  });
                },
              )
            ],
          ),
        ): null
    );
  }
}
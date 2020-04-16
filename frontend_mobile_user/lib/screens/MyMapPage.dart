import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../json_serializable/locations.dart' as locations;

class MyMapPage extends StatefulWidget {
  MyMapPage({Key key, this.title}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.
  final String title;
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {

  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinPharmaIcon;
  final Map<String, Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  LatLng myPinPosition;

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/myLocationIcon.png').then((onValue) {
      pinLocationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5),
        'assets/images/pharmaIcon.png').then((onValue) {
      pinPharmaIcon = onValue;
    });
    myPinPosition = LatLng(36.849237, 10.141989);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    final googleDrugStores = await locations.getGoogleDrugStores();
    setState(() {
      _markers.clear();

      final myMarker = Marker(
          markerId: MarkerId("MyLocation"),
          position: myPinPosition,
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

  @override
  Widget build(BuildContext context) {


    CameraPosition initialLocation = CameraPosition(
        zoom: 14,
        bearing: 30,
        target: myPinPosition
    );

    return GoogleMap(
      myLocationEnabled: true,
      initialCameraPosition: initialLocation,
      onMapCreated: _onMapCreated,
      markers: _markers.values.toSet(),
    );
  }

}
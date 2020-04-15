import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

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

class MyMapPage extends StatefulWidget {
  MyMapPage({Key key, this.title}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.
  final String title;
  @override
  _MyMapPageState createState() => _MyMapPageState();
}





class _MyMapPageState extends State<MyMapPage> {


  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleDrugStores = await locations.getGoogleDrugStores();
    setState(() {
      _markers.clear();
      for (final drugStore in googleDrugStores.drugStores) {
        final marker = Marker(
          markerId: MarkerId(drugStore.name),
          position: LatLng(drugStore.lat, drugStore.lng),
          infoWindow: InfoWindow(
            title: drugStore.name,
            snippet: drugStore.address,
          ),
        );
        _markers[drugStore.name] = marker;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Map Mawjood'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: const LatLng(36.849237, 10.141989),
            zoom: 14,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }

}

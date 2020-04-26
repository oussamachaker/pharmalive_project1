
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend_mobile_user/common/divider_with_text_widget.dart';
// import '../json_serializable/locations.dart';
import 'dart:async';
import '../json_serializable/locations.dart' as locations;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen ({Key key, this.title}) : super(key: key);
  // It is stateful, meaning that it has a State object (defined below)
  // that contains fields that affect how it looks.
  final String title;
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen > {


  TextEditingController _searchController = new TextEditingController();
  Timer _throttle;
  List<locations.DrugStore> _drugStores;

  @override
  void initState() {
    super.initState();
    _drugStores = new List<locations.DrugStore>();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(_searchController.text);
    });
  }

  void getLocationResults(String input) async {
    if (input.isEmpty) {
      return;
    }
    print(" searching " + input);
    final getDrugStores = await locations.getGoogleDrugStores();
    //RegExp exp = new RegExp(r'(' + input + '+)');
    setState(() {
      _drugStores.clear();
      for (final drugStore in getDrugStores.drugStores) {
        //print(" is there match ? " + exp.hasMatch(drugStore.address).toString() + "   for   " + drugStore.address);
        if(drugStore.address.toLowerCase().contains(input.toLowerCase()) || drugStore.name.toLowerCase().contains(input.toLowerCase())){
          _drugStores.add(drugStore);
        }
        print(drugStore.address.toString() + " " + drugStore.address.toLowerCase().contains(input.toLowerCase()).toString() );
        print(drugStore.name.toString() + " " + drugStore.name.toLowerCase().contains(input.toLowerCase()).toString() );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
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
                  Text("LOCATE DRUGSTORE",style: TextStyle(fontSize: 20, color: Colors.black)),
                  Icon(Icons.navigate_before, color: Colors.transparent),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: new DividerWithText(
                dividerText: (_drugStores.isNotEmpty)?"Suggestions":"No Results",
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _drugStores.length,
                itemBuilder: (BuildContext context, int index) =>
                    buildPlaceCard(context, index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceCard(BuildContext context, int index) {
    return Hero(
      tag: _drugStores[index].id,
      transitionOnUserGestures: true,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Card(
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: AutoSizeText(_drugStores[index].name,
                                    maxLines: 2,
                                    style: TextStyle(fontSize: 20.0)),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: AutoSizeText(_drugStores[index].address,
                                    maxLines: 2,
                                    style: TextStyle(fontSize: 10.0)),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text("Number of Face Mask : ${_drugStores[index].numberFaceMask.toString()}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
//                  Column(
//                    children: <Widget>[
//                     Placeholder(
//                       fallbackHeight: 80,
//                        fallbackWidth: 80,
//                     ),
//                    ],
//                  )
                ],
              ),
              onTap: () {
                print("tapped : " + _drugStores[index].lat.toString() + " " + _drugStores[index].lng.toString());
                LatLng returnedValue = LatLng(_drugStores[index].lat , _drugStores[index].lng);
                Navigator.pop(context, returnedValue);
              },
            ),
          ),
        ),
      ),
    );
  }

}
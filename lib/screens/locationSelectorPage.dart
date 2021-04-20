import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/screens/homePage.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';


class LocationSelectorPage extends StatefulWidget {
  static const routeName = '/selectLocation';
  final bool backHome; 

  LocationSelectorPage([this.backHome=true]);

  @override
  _LocationSelectorPageState createState() => _LocationSelectorPageState(backHome);

}

class _LocationSelectorPageState extends State<LocationSelectorPage> {

  MapController _controller = MapController();
  static LatLng initialLocation = LatLng(41.395247, 2.169878);
  LatLng markerLocation = initialLocation;
  final bool backHome;

  _LocationSelectorPageState([this.backHome=true]);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('¿Dónde quieres buscar?'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
                center: initialLocation,
                zoom: 14.0,
                onTap: (LatLng position) {
                  setState(() {
                    markerLocation = position;
                  });
                },
                controller: _controller
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']
              ),
              MarkerLayerOptions(markers: [Marker(
                width: 80.0,
                height: 80.0,
                point: markerLocation,
                builder: (ctx) => Container(
                  child: Icon(Icons.my_location),
                ),
              )])
            ],
            mapController: _controller
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 10, spreadRadius: 0)],
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.black, size: 24,),
                onPressed: () {
                  context.read<SelectedTab>().changeLoc(LocationData.fromMap({
                    'latitude': markerLocation.latitude,
                    'longitude': markerLocation.longitude
                  }));
                  print(backHome);
                  if (backHome) {
                    Navigator.pushReplacementNamed(
                      context,
                      HomePage.routeName,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                }
              ),
            ),
            bottom: 40,
            right: 20,
          )
        ]
      ),
    );
  }

}
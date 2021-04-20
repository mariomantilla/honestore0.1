import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:honestore/models/vendor.dart';
import 'package:latlong/latlong.dart';

class VendorPage extends StatelessWidget {

  static const routeName = '/vendor';

  @override
  Widget build(BuildContext context) {

    final Vendor vendor = ModalRoute.of(context).settings.arguments;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
          title: Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.directions_transit),
            FlutterMap(
              options: MapOptions(
                  center: LatLng(0,0),
                  zoom: 14.0,
                  onTap: (LatLng position) {print(position);}
              ),
              layers: [
                TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
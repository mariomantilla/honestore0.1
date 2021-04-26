import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:honestore/models/product.dart';
import 'package:latlong/latlong.dart';

class ProductsMapView extends StatelessWidget {

  final List<Product> products;
  final LatLng location;
  final MapController _controller = MapController();

  ProductsMapView(this.products, this.location);

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = products.map<Marker>((product){return Marker(
      width: 80.0,
      height: 80.0,
      point: product.location,
      builder: (ctx) =>
          Container(
            child: Icon(Icons.place),
          ),
    );}).toList();
    markers.add(Marker(
      width: 80.0,
      height: 80.0,
      point: location,
      builder: (ctx) =>
          Container(
            child: Icon(Icons.my_location, color: Colors.blue, size: 16, ),
          ),
    ));
    FlutterMap map = FlutterMap(
        options: MapOptions(
            center: location,
            zoom: 14.0,
            interactiveFlags: InteractiveFlag.all,
            onTap: (LatLng position) {print(position);},
            controller: _controller
        ),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
          ),
          MarkerLayerOptions(
            markers: markers,
          ),
        ],
        mapController: _controller
    );
    return Stack(children: [
      map,
      Positioned(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: IconButton(
              icon: Icon(Icons.my_location, color: Colors.black,),
              onPressed: () {
                if (_controller.ready) {
                  _controller.move(location, 14.0);
                }
              }
          ),
        ),
        bottom: 40,
        right: 20,
      )
    ],);
  }
}
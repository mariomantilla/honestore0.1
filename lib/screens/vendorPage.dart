import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:honestore/models/vendor.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorPage extends StatelessWidget {

  static const routeName = '/vendor';
  final Vendor vendor;

  VendorPage({this.vendor});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(20), child: Text(vendor.name, style: TextStyle(fontSize: 24),),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.email, color: Colors.black,),
                onPressed: () {
                  launch("mailto:"+vendor.email);
                },
              ),
              IconButton(
                icon: Icon(Icons.phone, color: Colors.black,),
                onPressed: () {
                  launch("tel://"+vendor.phone);
                },
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.black,),
                onPressed: () {
                  launch("https://api.whatsapp.com/send?phone=${vendor.whatsapp}&text=Hola, tengo algunas preguntas sobre to producto");
                },
              )
            ],
          ),
          Divider(height: 1,),
          ListTile(
            leading: Icon(Icons.store_sharp, color: Colors.black,),
            minLeadingWidth: 0,
            title: Text('Localización'),
            subtitle: Text(vendor.address),
          ),
          Container(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: vendor.location,
                    zoom: 14.0,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']
                    ),
                    MarkerLayerOptions(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: vendor.location,
                          builder: (ctx) =>
                              Container(
                                child: Icon(Icons.place),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,

                    ),
                    child: IconButton(
                        icon: Icon(Icons.open_in_new, color: Colors.black,),
                        onPressed: () {
                          if (Theme.of(context).platform == TargetPlatform.android) {
                            AndroidIntent intent = AndroidIntent(
                              action: 'action_view',
                              data: 'geo:${vendor.location.latitude.toString()},${vendor.location.longitude.toString()}?q=${vendor.location.latitude.toString()},${vendor.location.longitude.toString()}(${Uri.encodeComponent(vendor.name)})',
                            );
                            intent.launch();
                          }
                        }
                    ),
                  ),
                  top: 10,
                  right: 10,
                )
              ],
            ),
            height: 200,
          ),
        ],
      ),
    );
  }

}
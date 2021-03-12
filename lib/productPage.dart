import 'package:ethical_shopping/vendorPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import 'product.dart';

class ProductPage extends StatefulWidget {

  final Product product;

  ProductPage({Key key, this.product}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState(product: product);
}

class _ProductPageState extends State<ProductPage> {

  Product product;

  _ProductPageState({this.product});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              /*centerTitle: true,
              title: Text(product.name, style: TextStyle(
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10)
                  ]
              )),*/
              background: Image(
                  fit: BoxFit.cover,
                  image: product.image
              )
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.shopping_bag),
                onPressed: () { /* ... */ },
              ),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () { /* ... */ },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share('Mira este producto en MatterBasket https://matterbasket.com/productos/${product.id}');
                },
              ),
            ]
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ListTile(
                title: Text(product.name, style: TextStyle(
                  fontSize: 24
                )),
              ),
              ListTile(
                title: Row(
                  children: [
                    Text('Vendido por: '),
                    Expanded(
                      child: InkWell(
                        child: Text(product.vendor.name,
                          style: TextStyle(
                            color: Colors.blueGrey
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => VendorPage(
                                    vendor: product.vendor,
                                  )
                              )
                          );
                        },
                     ),
                    ),
                    Text(f.format(product.price.toDouble()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                      ),)
                  ]
                )
              ),
              Container(
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        center: product.location,
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
                              point: product.location,
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
                                data: 'geo:${product.location.latitude.toString()},${product.location.longitude.toString()}?q=${product.location.latitude.toString()},${product.location.longitude.toString()}(${Uri.encodeComponent(product.name)})',
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
              Container(
                height: 3000,
                child: Text('a')
              )
            ]),
          ),
        ],
      ),
    );
  }
}
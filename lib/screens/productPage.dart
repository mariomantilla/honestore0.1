import 'package:honestore/widgets/picsCarousel.dart';

import 'package:honestore/screens/vendorPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

import 'package:honestore/models/product.dart';
import 'package:honestore/models/tag.dart';
import 'package:honestore/widgets/link.dart';

class ProductPage extends StatelessWidget {
  static const routeName = '/product';
  final Product product;

  ProductPage({this.product});

  Future<void> _tagInfoModal(context, Tag tag) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tag.name),
          content: SingleChildScrollView(
            child: Text(tag.description),
          ),
        );
      },
    );
  }

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
                background: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Scaffold(
                              body: PicsCarousel(product.images, fit: BoxFit.contain, pinch: true),
                            )
                        )
                    );
                  },
                  child: PicsCarousel(product.images),
                ),
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
              Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(product.name,
                            style: TextStyle(
                                fontSize: 24
                            )
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [for (int i=1; i<6; i++) Icon(i <= product.rating ? Icons.star : Icons.star_border, color: Colors.amber,)],
                    ),
                  ]
              ),
              ListTile(
                  title: Row(
                      children: [
                        Text('Vendido por: '),
                        Expanded(
                          child: Link(
                            text: product.vendor.name,
                            action: () {
                              Navigator.pushNamed(
                                  context,
                                  VendorPage.routeName,
                                  arguments: product.vendor
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
              Divider(height: 0,),
              Padding(
                padding: EdgeInsets.all(16),
                child: MarkdownBody(
                  styleSheet: MarkdownStyleSheet(
                      textAlign: WrapAlignment.spaceEvenly
                  ),
                  selectable: true,
                  data: product.description,
                ),
              ),
              Divider(height: 0,),
              Padding(
                padding: EdgeInsets.only(top: 10, right: 15, bottom: 10, left: 15),
                child: Wrap(
                  spacing: 5.0, // spacing between adjacent chips
                  runSpacing: 5.0,
                  children: product.tags.map((tag){
                    return GestureDetector(
                      child: Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tag.name),
                            Icon(Icons.contact_support)
                          ],
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelPadding: EdgeInsets.only(left: 4),
                      ),
                      onTap: () {
                        _tagInfoModal(context, tag);
                      },
                    );
                  }).toList(),
                ),
              ),
              Divider(height: 0,),
              ListTile(
                  leading: Icon(Icons.store_sharp, color: Colors.black,),
                  minLeadingWidth: 0,
                  title: Text('Disponible para recoger')
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
            ]),
          ),
        ],
      ),
    );

  }
}

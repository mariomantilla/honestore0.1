import 'dart:convert';
import 'package:ethical_shopping/productPage.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'category.dart';
import 'product.dart';
import 'vendor.dart';
import 'vendorPage.dart';

class ListingPage extends StatefulWidget {

  final Category category;
  final String search;

  ListingPage({Key key, this.category, this.search}) : super(key: key);

  @override
  _ListingPageState createState() => _ListingPageState(category: category, search: search);

}

class _ListingPageState extends State<ListingPage> {

  Category category;
  String search = '';
  Future<List<Product>> products;

  _ListingPageState({this.category, this.search});

  Future<List<Product>> fetchProducts() async {
    final searchFilter = ((search != '') & (search != null)) ? 'FIND(\'${search.toLowerCase()}\',LOWER({name}))' : '1';
    final catFilter = category != null ? 'FIND(\'${category.id}\',{categories})' : '1';
    final filters = 'AND(' + searchFilter + ',' + catFilter + ')';
    final response = await http.get(
        Uri.https(
            'api.airtable.com',
            '/v0/appft8jvxQwHFoE4f/Products',
            {'filterByFormula': filters}
        ),
        headers: {
          'Authorization': 'Bearer keyRE1c1hmHxqgebK'
        }
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['records'];
      return data.map<Product>((element) {
        return Product(
          id: element['id'],
          name: element['fields']['name'],
          categories: element['fields']['categories'].map<int>((cat){return int.parse(cat);}).toList(),
          image: NetworkImage(element['fields']['picture'][0]['thumbnails']['large']['url']),
          price: Decimal.parse(element['fields']['price'].toString()),
          vendor: Vendor(name: element['fields']['vendorName'][0]),
          location: LatLng(element['fields']['lat'], element['fields']['lon'])
        );
      }).toList();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    products = fetchProducts();
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(1),
              enabledBorder: InputBorder.none,
              hintText: category != null ? 'Buscar en '+ category.title + '...' : 'Buscar...',
              hintStyle: TextStyle(color: Colors.white,),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
            onSubmitted: (String text) {
              setState(() {
                search = text;
              });
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt, color: Colors.white),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext bc) {
                      return Column(
                        children: [
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Text('Filtros',
                              style: TextStyle(
                                  fontSize: 25
                              )
                          ),
                          Divider(),
                          ListTile(
                            title: Text('Categoría:'),
                            subtitle: Chip(
                              label: Text(widget.category != null ? widget.category.title : ''),
                              deleteIcon: Icon(Icons.close_outlined),
                              onDeleted: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      );
                    }
                );
              },
            )
          ],
      ),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.length == 0) {
              return Center(
                  child: Text('Ops! Parece que no hemos encontrado por aquí.')
              );
            }
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 5
                ),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctx, index) {
                  final f = NumberFormat.currency(locale: 'es_ES', symbol: '€');
                  return InkWell(
                    child: Card(
                        child: Column(
                          children: [
                            SizedBox(
                              child: Image(
                                image: snapshot.data[index].image,
                                fit: BoxFit.cover,
                              ),
                              width: double.infinity,
                              height: 170,
                            ),
                            ListTile(
                              title: Text(f.format(snapshot.data[index].price.toDouble())),
                              subtitle: InkWell(
                                child: Text(snapshot.data[index].vendor.name),
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => VendorPage(
                                            vendor: snapshot.data[index].vendor,
                                          )
                                      )
                                  );
                                },
                              ),
                            )
                          ],
                        )
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => ProductPage(
                                product: snapshot.data[index],
                              )
                          )
                      );
                    },
                  );
                }
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString())
            );
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator(backgroundColor: Colors.black,));
        },
      ),
    );
  }
}
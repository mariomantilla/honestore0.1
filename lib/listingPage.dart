import 'dart:convert';
import 'productPage.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'models/vendor.dart';
import 'models/tag.dart';
import 'vendorPage.dart';
import 'widgets/filterSheet.dart';

class ListingPage extends StatefulWidget {

  final Category category;
  final String search;
  final List<Tag> tags;
  final List<Category> availableCategories;


  ListingPage({Key key, this.category, this.search, this.tags, this.availableCategories}) : super(key: key);

  @override
  _ListingPageState createState() => _ListingPageState(category: category, search: search, tags: tags??[], availableCategories: availableCategories);

}

class _ListingPageState extends State<ListingPage> {

  Category category;
  String search = '';
  List<Tag> tags = [];
  Future<List<Product>> products;
  final List<Category> availableCategories;
  List<Tag> availableTags = [];

  _ListingPageState({this.category, this.search, this.tags, this.availableCategories});

  Future<List<Product>> fetchProducts() async {
    final searchFilter = ((search != '') & (search != null)) ? 'OR(FIND(\'${search.toLowerCase()}\',LOWER({name})),FIND(\'${search.toLowerCase()}\',LOWER({description})))' : '1';
    final catFilter = category != null ? 'FIND(\'${category.id}\',{categories})' : '1';
    String tagFilter = '1';
    if (tags.isNotEmpty) {
      String tagsFormula = tags.map<String>((tag){return 'FIND(\'${tag.name}\',ARRAYJOIN({tagsName})),';}).toList().join();
      tagFilter = 'OR(' + tagsFormula + '0)';
    }
    final filters = 'AND(' + searchFilter + ',' + catFilter + ',' + tagFilter + ')';
    print(filters);
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
        final fields = element['fields'];
        return Product(
          id: element['id'],
          name: fields['name'],
          description: fields['description'],
          categories: fields['categories'].map<int>((cat){return int.parse(cat);}).toList(),
          images: fields['picture'].map<NetworkImage>((data) {return NetworkImage(data['thumbnails']['large']['url']);}).toList(),
          price: Decimal.parse(fields['price'].toString()),
          vendor: Vendor(name: fields['vendorName'][0]),
          location: LatLng(fields['lat'], element['fields']['lon']),
          tags: [for (int i = 0; i < fields['tags'].length ; i++) Tag(
            id: fields['tags'][i],
            name: fields['tagsName'][i],
            description: fields['tagsDescription'][i]
          )],
          rating: fields['rating']/1
        );
      }).toList();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load products');
    }
  }

  Future<List<Tag>> fetchTags() async {

    final response = await http.get(
        Uri.https(
            'api.airtable.com',
            '/v0/appft8jvxQwHFoE4f/Tags'
        ),
        headers: {
          'Authorization': 'Bearer keyRE1c1hmHxqgebK'
        }
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['records'];
      return data.map<Tag>((element) {
        final fields = element['fields'];
        return Tag(
          id: element['id'],
          name: fields['name'],
          description: fields['description'],
        );
      }).toList();
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load tags');
    }
  }

  _navigateAndDisplayFilters(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final newFilters = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return FilterSheet(
            category: category,
            tags: tags,
            availableCategories: availableCategories,
            availableTags: availableTags,
          );
        }
    );
    setState(() {
      category = newFilters['category'];
      tags = newFilters['tags'];
    });
  }

  @override
  Widget build(BuildContext context) {
    products = fetchProducts();
    fetchTags().then((value) {availableTags = value;});
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
                _navigateAndDisplayFilters(context);
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sentiment_dissatisfied_rounded, size: 64,),
                    Text('Ops! Parece que no hemos encontrado nada con esos filtros.', style: TextStyle(fontSize: 24), textAlign: TextAlign.center,)
                  ],
                ),
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
                              child: FadeInImage(
                                placeholder: AssetImage('images/loading.gif'),
                                image: snapshot.data[index].images[0],
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
          return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,));
        },
      ),
    );
  }
}
import 'package:flutter_map/flutter_map.dart';
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/services/airtable.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:honestore/models/category.dart';
import 'package:honestore/models/product.dart';
import 'package:honestore/models/vendor.dart';
import 'package:honestore/models/tag.dart';
import 'package:honestore/widgets/filterSheet.dart';
import 'package:honestore/screens/productPage.dart';
import 'package:honestore/screens/vendorPage.dart';
import 'package:provider/provider.dart';


class ListingFilters {

  Category category;
  String search;
  List<Tag> tags;

  ListingFilters({this.category, this.search = '', this.tags = const []});

}

class ListingPage extends StatefulWidget {

  static const routeName = '/listing';

  final ListingFilters filters;

  ListingPage({Key key, this.filters}) : super(key: key);

  @override
  _ListingPageState createState() => _ListingPageState(filters: filters);

}

class _ListingPageState extends State<ListingPage> {

  ListingFilters filters;
  Future<List<Product>> products;
  List<Tag> availableTags = [];
  //Location location = Location();
  LocationData currentLocation;

  _ListingPageState({this.filters});

  Future<List<Product>> fetchProducts() async {

    if (currentLocation == null) {
      return [];
    }

    var search = filters.search;
    var category = filters.category;
    var tags = filters.tags;

    final searchFilter = ((search != '') & (search != null)) ? 'OR(FIND(\'${search.toLowerCase()}\',LOWER({name})),FIND(\'${search.toLowerCase()}\',LOWER({description})))' : '1';
    final catFilter = category != null ? 'FIND(\'${category.id}\',{categories})' : '1';
    String tagFilter = '1';
    if (tags.isNotEmpty) {
      String tagsFormula = tags.map<String>((tag){return 'FIND(\'${tag.name}\',ARRAYJOIN({tagsName})),';}).toList().join();
      tagFilter = 'OR(' + tagsFormula + '0)';
    }
    final filtersString = 'AND(' + searchFilter + ',' + catFilter + ',' + tagFilter + ')';

    List data = await Airtable().getRecords('Products', {'filterByFormula': filtersString});
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
        rating: fields['rating']/1,
        targetLocation: currentLocation
      );
    }).toList();

  }

  Future<List<Tag>> fetchTags() async {

    List data = await Airtable().getRecords('Tags');
    return data.map<Tag>((element) {
      final fields = element['fields'];
      return Tag(
        id: element['id'],
        name: fields['name'],
        description: fields['description'],
      );
    }).toList();

  }

  _navigateAndDisplayFilters(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final newFilters = await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return FilterSheet(
            category: filters.category,
            tags: filters.tags,
            availableTags: availableTags,
            currentLocation: currentLocation,
          );
        }
    );
    if (newFilters != null) {
      setState(() {
        filters.category = newFilters['category'];
        filters.tags = newFilters['tags'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    currentLocation = context.select<SelectedTab, LocationData>(
          (s) => s.currentLocation,
    );
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
              hintText: filters.category != null ? 'Buscar en '+ filters.category.title + '...' : 'Buscar...',
              hintStyle: TextStyle(color: Colors.white,),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
            onSubmitted: (String text) {
              setState(() {
                filters.search = text;
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
              if (currentLocation == null) {
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,));
              }
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

            return ResultsWidget(snapshot.data, LatLng(currentLocation.latitude, currentLocation.longitude));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString())
            );
          }
          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,));
        },
      ),
      bottomNavigationBar: BottomTabsWidget(),
    );
  }
}
class BottomTabsWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var index = context.select<SelectedTab, int>(
          (s) => s.selectedTab,
    );
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: '',
        ),
      ],
      currentIndex: index,
      selectedItemColor: Colors.amber[800],
      onTap: (int index) {
        context.read<SelectedTab>().changeTab(index);
      },
    );
  }
}

class ResultsWidget extends StatefulWidget {

  final List<Product> products;
  final LatLng location;

  ResultsWidget(this.products, this.location);

  @override
  ResultsWidgetState createState() => ResultsWidgetState(products, location);

}

class ResultsWidgetState extends State<ResultsWidget> {

  final List<Product> products;
  final LatLng location;
  MapController _controller = MapController();

  ResultsWidgetState(this.products, this.location);

  Widget gridView(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 5
        ),
        itemCount: products.length,
        itemBuilder: (BuildContext ctx, index) {
          final f = NumberFormat.currency(locale: 'es_ES', symbol: '€');
          return InkWell(
            child: Card(
                child: Column(
                  children: [
                    SizedBox(
                      child: FadeInImage(
                        placeholder: AssetImage('images/loading.gif'),
                        image: products[index].images[0],
                        fit: BoxFit.cover,
                      ),
                      width: double.infinity,
                      height: 170,
                    ),
                    ListTile(
                      title: Text(f.format(products[index].price.toDouble())),
                      subtitle: InkWell(
                        child: Text(products[index].vendor.name),
                        onTap: () {
                          Navigator.pushNamed(
                              context,
                              VendorPage.routeName,
                              arguments: products[index].vendor
                          );
                        },
                      ),
                      trailing: Text(products[index].displayDistance()),
                    )
                  ],
                )
            ),
            onTap: () {
              print(products[index]);
              Navigator.pushNamed(context,
                ProductPage.routeName,
                arguments: products[index],
              );
            },
          );
        }
    );
  }

  Widget mapView(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    var index = context.select<SelectedTab, int>(
      // Here, we are only interested in the item at [index]. We don't care
      // about any other change.
          (s) => s.selectedTab,
    );
    final widgets = [gridView, mapView];
    return widgets[index](context);
  }
}
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/services/backend.dart';
import 'package:honestore/widgets/productsGridView.dart';
import 'package:honestore/widgets/productsMapView.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:honestore/models/category.dart';
import 'package:honestore/models/product.dart';
import 'package:honestore/models/tag.dart';
import 'package:honestore/widgets/filterSheet.dart';
import 'package:provider/provider.dart';


class ListingFilters {

  Category category;
  String search;
  List<Tag> tags;
  List<String> productsIDs;

  ListingFilters({this.category, this.search = '', this.tags = const [], this.productsIDs});

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
  Key key = UniqueKey();
  //Future<List<Product>> products;

  _ListingPageState({this.filters});

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
    LocationData currentLocation = context.select<SelectedTab, LocationData>(
          (s) => s.currentLocation,
    );
    Future<List<Product>> products = Backend().getProducts(filters, currentLocation);
    return Scaffold(
      key: key,
      appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(1),
              enabledBorder: InputBorder.none,
              hintText: filters.category != null ? 'Buscar en '+ filters.category.name + '...' : 'Buscar...',
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
          if (snapshot.error != null) {print(snapshot.error);return Center(child: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                key = UniqueKey();
              });
            },
          ));}
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
                  ]
                ),
              );
            }
            int index = context.select<SelectedTab, int>(
                  (s) => s.selectedTab,
            );
            final widgets = [ProductsGridView(snapshot.data), ProductsMapView(snapshot.data, LatLng(currentLocation.latitude, currentLocation.longitude))];
            return widgets[index];
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

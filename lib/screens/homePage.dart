import 'package:flutter/material.dart';
import 'package:honestore/models/category.dart';
import 'package:honestore/screens/locationSelectorPage.dart';
import 'package:provider/provider.dart';

import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/screens/listingPage.dart';
import 'package:location/location.dart';


class HomePage extends StatefulWidget {

  static const routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _locationModal(context) async {
    return showDialog<void>(
      barrierColor: Color(0x77000000),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Más cerca, mejor'),
          content: Text('Para poder mostrarte resultados relevantes necesitamos que nos digas donde quieres realizar la búsqueda.'),
          actions: [
            TextButton(onPressed: () {
              context.read<SelectedTab>().getLoc();
              Navigator.of(context).pop();
            }, child: Text('Localizacion actual')),
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                context,
                LocationSelectorPage.routeName,
                arguments: true
              );
            }, child: Text('Seleccionar en mapa')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    var currentLocation = context.select<SelectedTab, LocationData>(
          (s) => s.currentLocation,
    );
    if (currentLocation == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _locationModal(context);
      });
    }
    var categories = context.select<SelectedTab, List<Category>>(
          (s) => s.categories,
    );
    return Scaffold(
      drawer: Drawer(
          child: ListView(
            children: [],
          )
      ),
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(icon: Icon(Icons.reorder, color: Colors.white,), onPressed: () => Scaffold.of(context).openDrawer());
            }
        ),
        actions: [
          IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: () {
            Navigator.pushNamed(
                context,
                ListingPage.routeName,
                arguments: ListingFilters()
            );
          }),
          IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white,), onPressed: () {
          }),
        ],
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int index) {
            var data = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context,
                    ListingPage.routeName,
                    arguments: ListingFilters(category: data)
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
                    image: data.image,
                  ),
                ),
                child: Center(child: Text(
                    data.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 10)
                        ]
                    )
                )),
              )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      )
    );
  }

}
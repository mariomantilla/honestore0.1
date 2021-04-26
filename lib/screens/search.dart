import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:honestore/models/product.dart';
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/screens/listingPage.dart';
import 'package:honestore/services/backend.dart';
import 'package:honestore/styles/appTheme.dart';
import 'package:honestore/widgets/productsGridView.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {

  static const routeName = '/';

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  ListingFilters filters = ListingFilters();
  int view = 0;

  @override
  Widget build(BuildContext context) {
    Future<List<Product>> products = context.select<SelectedTab, Future<List<Product>>>(
          (s) => Backend().getProducts(filters, s.currentLocation),
    );
    return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Buscar...',
                  suffixIcon: IconButton(
                    icon: Icon(view==0?Icons.map:FontAwesomeIcons.stream),
                    onPressed: () {
                      setState(() {
                        view==0 ? view=1 : view=0;
                      });
                    },
                  )
                ),
                onSubmitted: (String text) {
                  setState(() {
                    filters.search = text;
                  });
                },
              ),
            ),
            Divider(height: 1,),
            Row(
              children: [
                if (filters.category!=null) Chip(label: Text(filters.category.name))
              ],
            ),
            Divider(height: 1,),
            FutureBuilder(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.error != null) {print(snapshot.error);return Expanded(child: Icon(Icons.signal_wifi_off));}
                if (snapshot.data.length == 0) {
                return Expanded(child: Text('No hay resultados'));
                }
                return Flexible(
                    child: ProductsGridView(snapshot.data, paddingTop: 20,),
                  );
                }
                return Expanded(child: Center(child: CircularProgressIndicator()));
              },
            )
          ],
        )
    );
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 25, bottom: 15, right: 30, left: 30),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: appTheme.canvasColor,
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(3, 3), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(children: [Text('Hola')],),
      ),
    );
  }

}
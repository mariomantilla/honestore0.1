import 'package:flutter/material.dart';
import 'package:honestore/models/product.dart';
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/screens/listingPage.dart';
import 'package:honestore/services/backend.dart';
import 'package:honestore/widgets/productsGridView.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';


class FavouritesList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    LocationData currentLocation = context.select<SelectedTab, LocationData>(
          (s) => s.currentLocation,
    );
    Future<List<Product>> products = context.select<SelectedTab, Future<List<Product>>>(
      (s) => Backend().getProducts(ListingFilters(productsIDs: s.favourites), currentLocation),
    );
    return FutureBuilder(
      future: products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.error != null) {print(snapshot.error);return Center(child: Icon(Icons.signal_wifi_off));}
          if (snapshot.data.length == 0) {
            return Center(child: Text('Aún no tienes favoritos'));
          }
          return ProductsGridView(snapshot.data);
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

}
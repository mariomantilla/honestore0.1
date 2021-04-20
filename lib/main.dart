import 'package:flutter/material.dart';
import 'package:honestore/screens/listingPage.dart';
import 'package:honestore/screens/locationSelectorPage.dart';
import 'package:provider/provider.dart';
import 'models/selectedTab.dart';
import 'styles/appTheme.dart';
import 'package:honestore/screens/vendorPage.dart';
import 'package:honestore/screens/productPage.dart';
import 'package:honestore/screens/homePage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectedTab(),
      child: MaterialApp(
        title: 'Honestore',
        theme: appTheme,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          var routes = <String, WidgetBuilder>{
            HomePage.routeName: (ctx) => HomePage(),
            ProductPage.routeName: (ctx) => ProductPage(product: settings.arguments),
            VendorPage.routeName: (ctx) => VendorPage(),
            ListingPage.routeName: (ctx) => ListingPage(filters: settings.arguments),
            LocationSelectorPage.routeName: (ctx) => LocationSelectorPage(settings.arguments),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        },
      ),
    );
  }
}



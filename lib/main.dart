import 'package:flutter/material.dart';
import 'styles/appTheme.dart';
import 'package:honestore/screens/vendorPage.dart';
import 'package:honestore/screens/productPage.dart';
import 'package:honestore/screens/homePage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Honestore',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        HomePage.routeName: (context) => HomePage(),
        ProductPage.routeName: (context) => ProductPage(),
        VendorPage.routeName: (context) => VendorPage(),
      },
    );
  }
}


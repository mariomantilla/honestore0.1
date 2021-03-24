import 'package:flutter/material.dart';
import 'package:honestore/models/vendor.dart';

class VendorPage extends StatelessWidget {

  static const routeName = '/vendor';

  @override
  Widget build(BuildContext context) {

    final Vendor vendor = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text(vendor.name),
        ),
        body: Center()
    );
  }

}
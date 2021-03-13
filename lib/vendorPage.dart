import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/vendor.dart';

class VendorPage extends StatefulWidget {

  final Vendor vendor;

  VendorPage({Key key, this.vendor}) : super(key: key);

  @override
  _VendorPageState createState() => _VendorPageState(vendor: vendor);
}

class _VendorPageState extends State<VendorPage> {

  final Vendor vendor;

  _VendorPageState({this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vendor.name),
      ),
      body: Center()
    );
  }
}
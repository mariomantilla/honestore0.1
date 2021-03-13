import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'vendor.dart';
import 'tag.dart';

class Product {
  final String id;
  final String name;
  final List<int> categories;
  final NetworkImage image;
  final Decimal price;
  final Vendor vendor;
  final LatLng location;
  final List<Tag> tags;

  Product({this.id, this.name, this.categories, this.image, this.price, this.vendor, this.location, this.tags});

}
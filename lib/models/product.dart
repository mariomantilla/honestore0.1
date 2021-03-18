import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'vendor.dart';
import 'tag.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<int> categories;
  final List<NetworkImage> images;
  final Decimal price;
  final Vendor vendor;
  final LatLng location;
  final List<Tag> tags;
  final double rating;

  Product({this.id, this.name, this.description, this.categories, this.images, this.price, this.vendor, this.location, this.tags, this.rating});

}
import 'dart:math' show cos, sqrt, asin;
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

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
  int distance;

  Product({this.id, this.name, this.description, this.categories, this.images, this.price, this.vendor, this.location, this.tags, this.rating, LocationData targetLocation}) {
    this.distance = 0;
    if (targetLocation != null) {
      this.distance = calculateDistance(targetLocation.latitude, targetLocation.longitude, location.latitude, location.longitude).round();
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}
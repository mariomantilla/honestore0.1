import 'package:flutter/cupertino.dart';
import 'product.dart';

class Category {
  final int id;
  final String title;
  final AssetImage image;
  List<Product> products = [];

  Category(this.id, this.title, this.image, this.products);
}
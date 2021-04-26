import 'package:flutter/material.dart';
import 'package:honestore/models/product.dart';
import 'package:honestore/screens/productPage.dart';
import 'package:honestore/screens/vendorPage.dart';
import 'package:intl/intl.dart';

class ProductsGridView extends StatelessWidget {

  final List<Product> products;
  final double paddingTop;

  const ProductsGridView(this.products, {this.paddingTop=0});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: EdgeInsets.only(left: 20, right: 20, top: paddingTop),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 5
        ),
        itemCount: products.length,
        itemBuilder: (BuildContext ctx, index) {
          final f = NumberFormat.currency(locale: 'es_ES', symbol: '€');
          return InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: FadeInImage(
                      placeholder: AssetImage('images/loading.gif'),
                      image: products[index].images[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 170,
                    ),
                  ),
                  ListTile(
                    title: Text(f.format(products[index].price.toDouble())),
                    subtitle: InkWell(
                      child: Text(products[index].vendor.name),
                      onTap: () {
                        Navigator.pushNamed(
                            context,
                            VendorPage.routeName,
                            arguments: products[index].vendor
                        );
                      },
                    ),
                    trailing: Text(products[index].displayDistance()),
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context,
                ProductPage.routeName,
                arguments: products[index],
              );
            },
          );
        }
    );
  }
}
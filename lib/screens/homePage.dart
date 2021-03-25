import 'package:flutter/material.dart';
import 'package:honestore/models/category.dart';
import 'package:honestore/screens/listingPage.dart';


class HomePage extends StatefulWidget {

  static const routeName = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Category> categories = [];

  var data = [
    {
      "image": "alimentacion.jpg",
      "text": "Alimentación"
    }, {
      "image": "higiene.jpg",
      "text": "Higiene"
    }, {
      "image": "libros.jpg",
      "text": "Libros"
    }, {
      "image": "mascotas.jpg",
      "text": "Mascotas"
    }, {
      "image": "juguetes.jpg",
      "text": "Juguetes"
    }
  ];

  @override
  void initState() {
    super.initState();
    data.asMap().forEach((index, element) {
      categories.add(Category(
          index,
          element['text'],
          AssetImage('images/categories/' + element['image']),
          []
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView()
      ),
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) {
              return IconButton(icon: Icon(Icons.reorder, color: Colors.white,), onPressed: () => Scaffold.of(context).openDrawer());
            }
        ),
        actions: [
          IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ListingPage(
                      availableCategories: categories,
                    )
                )
            );
          }),
          IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white,), onPressed: () {
          }),
        ],
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 10),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            Category category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => ListingPage(
                          filters: ListingFilters(category: categories[index]),
                          availableCategories: categories,
                        )
                    )
                );
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
                    image: category.image,
                  ),
                ),
                child: Center(child: Text(
                    category.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 10)
                        ]
                    )
                )),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }

}
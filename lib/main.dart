import 'package:flutter/material.dart';
import 'models/category.dart';
import 'listingPage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethical Shopping',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        accentColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
        )
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

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
      "image": "jugetes.jpg",
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
                      search: '',
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
                          category: categories[index],
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

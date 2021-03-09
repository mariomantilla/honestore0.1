import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethical Shopping',
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        accentColor: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

  var data = [
    {
      "imageUrl": "https://images.theconversation.com/files/282104/original/file-20190701-105182-1q7a7ji.jpg?ixlib=rb-1.1.0&q=45&auto=format&h=200.0",
      "text": "Alimentación",
      "products": [
        {
          'name': 'Cereales'
        },
      ]
    }, {
      "imageUrl": "https://www.65ymas.com/uploads/s1/58/47/1/por-que-no-se-deben-compartir-productos-de-higiene-personal.jpeg",
      "text": "Higiene",
      "products": []
    }, {
      "imageUrl": "http://static1.squarespace.com/static/5c6d8645aadd344a28004478/5c6d876b971a1879d2d66ad4/5ea1c242061ba442a83aa09c/1587661481937/pestan%CC%83a+libros.jpg?format=1500w",
      "text": "Libros",
      "products": []
    }, {
      "imageUrl": "https://estaticos.muyinteresante.es/uploads/images/article/5e53ccda5cafe849c002505d/mascotas.jpg",
      "text": "Mascotas",
      "products": []
    }, {
      "imageUrl": "https://cdn.shopify.com/s/files/1/0273/6760/4324/files/Outle-2_1600x.png?v=1595608855",
      "text": "Juguetes",
      "products": []
    }
  ];

  var filters = {
    'category': -1,
    'search': ''
  };

  List<Map> statesHistory = [{'category': -1, 'search': ''}];

  List getProducts() {
    return data[filters['category']]['products'];
  }

  void newStatePage(Map<String, Object> changes) {
    setState(() {
      filters.addAll(changes);
      statesHistory.add(Map.from(filters));
    });
  }

  Widget getContentWidget() {
    return filters['category'] == -1 ? ListView.separated(
      padding: const EdgeInsets.only(top: 10),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            newStatePage({'category': index});
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
                image: NetworkImage(
                    data[index]['imageUrl']
                ),
              ),
            ),
            child: Center(child: Text(
                data[index]['text'],
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
    ) : GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20
        ),
        itemCount: getProducts().length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            alignment: Alignment.center,
            child: Text(getProducts()[index]["name"]),
            decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(15)),
          );
        }
    ) ;
  }

  bool isFiltered() {
    return filters['search'] != '' || filters['category'] != -1;
  }

  int getCategory() {
    return filters['category'];
  }

  String getCategoryName() {
    return getCategory() == -1 ? 'Todas' : data[filters['category']]['text'] ;
  }

  @override
  Widget build(BuildContext context) {
    //statesHistory.add(Map.from(filters));
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.reorder, color: Colors.white,), onPressed: () => {}),

            title: Container(
              height: 40.0,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(1),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      //labelText: 'Search',
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(isFiltered() ? Icons.filter_alt_outlined : Icons.filter_alt , color: Colors.white),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 10)),
                                Text('Filtros',
                                    style: TextStyle(
                                        fontSize: 25
                                    )
                                ),
                                Divider(),
                                ListTile(
                                  title: Text('Categoría:'),
                                  subtitle: Chip(
                                    label: Text(getCategoryName()),
                                    deleteIcon: Icon(Icons.close_outlined),
                                    onDeleted: () {
                                      newStatePage({'category': -1});
                                      Navigator.pop(context);
                                    },
                                  ),
                                )
                              ],
                            );
                          }
                      );
                    },
                  )
                ],
              ),
            ),
            actions: [
              IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white,), onPressed: () {}),
            ],
            elevation: 0.0,
            brightness: Brightness.dark,
          ),
          body: Center(
            child: getContentWidget(),
          ),
        ),
      onWillPop: () async {
        if (statesHistory.isNotEmpty) {
          setState(() {
            statesHistory.removeLast();
            statesHistory.last.forEach((key, value) {filters[key] = value;});
          });
          return false;
        }
        return true;
      }
    );
  }

}


class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center()
    );
  }
}

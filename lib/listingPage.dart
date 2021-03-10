import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'category.dart';
import 'product.dart';

class ListingPage extends StatefulWidget {

  final Category category;
  final String search;

  ListingPage({Key key, this.category, this.search}) : super(key: key);

  @override
  _ListingPageState createState() => _ListingPageState(category: category, search: search);

}

class _ListingPageState extends State<ListingPage> {

  Category category;
  String search = '';
  List<Product> products;

  _ListingPageState({Key key, this.category, this.search});

  @override
  void initState() {
    super.initState();
    /*data.asMap().forEach((index, element) {
      categories.add(Category(
          index,
          element['text'],
          AssetImage('images/categories/' + element['image']),
          []
      ));
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(1),
              enabledBorder: InputBorder.none,
              hintText: category != null ? 'Buscar en '+ category.title + '...' : 'Buscar...',
              hintStyle: TextStyle(color: Colors.white,),
            ),
            style: TextStyle(color: Colors.white, fontSize: 18),
            onSubmitted: (String text) {
              setState(() {
                search = text;
              });
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt, color: Colors.white),
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
                              label: Text(widget.category != null ? widget.category.title : ''),
                              deleteIcon: Icon(Icons.close_outlined),
                              onDeleted: () {
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
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20
          ),
          itemCount: (search ?? '').length,
          itemBuilder: (BuildContext ctx, index) {
            return Container(
              alignment: Alignment.center,
              child: Text((search ?? '').split('')[index]),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15)),
            );
          }
      )
    );
  }
}
import 'package:flutter/material.dart';
import 'package:honestore/models/selectedTab.dart';
import 'package:honestore/screens/locationSelectorPage.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

import '../models/tag.dart';

class FilterSheet extends StatefulWidget {

  final Category category;
  final List<Tag> tags;

  FilterSheet({Key key, this.category, this.tags}) : super(key: key);

  @override
  _FilterSheetState createState() => _FilterSheetState(category: category, tags: tags);
}

class _FilterSheetState extends State<FilterSheet> {

  Category category;
  List<Tag> tags = [];
  TextEditingController _autocompleteTextEditController;

  _FilterSheetState({this.category, this.tags});

  Future<void> _locationModal(context) async {
    return showDialog<void>(
      barrierColor: Color(0x77000000),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar ubicación'),
          content: Text('¿Cómo quieres seleccionar la ubicación para tu búsqueda?'),
          actions: [
            TextButton(onPressed: () {
              context.read<SelectedTab>().getLoc();
              Navigator.of(context).pop();
            }, child: Text('Localizacion actual')),
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                LocationSelectorPage.routeName,
                arguments: false
              );
            }, child: Text('Seleccionar en mapa')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var actualLocation = context.select<SelectedTab, bool>(
          (s) => s.actualLocation,
    );
    var availableCategories = context.select<SelectedTab, List<Category>>(
          (s) => s.categories,
    );
    var availableTags = context.select<SelectedTab, List<Tag>>(
          (s) => s.tags,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(padding: EdgeInsets.only(top: 10)),
        Text('Filtros',
            style: TextStyle(
                fontSize: 25
            )
        ),
        Divider(),
        ListTile(
          title: Row(
           children: [
             Text('Categoría:'),
             Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
             DropdownButton<Category>(
               value: category,
               onChanged: (Category cat) {
                 setState(() {
                   category = cat;
                 });
               },
               hint: Text('Selecciona categoría...'),
               items: availableCategories.map<DropdownMenuItem<Category>>((cat) {return DropdownMenuItem(child: Text(cat.name), value: cat);}).toList()
             ),
             IconButton(icon: Icon(Icons.clear), onPressed:() {
               setState(() {
                 category = null;
               });
             })
           ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, right: 15, left: 15),
          child: Wrap(
              spacing: 5.0, // spacing between adjacent chips
              runSpacing: 5.0,
              children: tags.map<GestureDetector>((tag){
                return GestureDetector(
                  child: Chip(
                    label: Text(tag.name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    deleteIcon: Icon(Icons.clear),
                    labelPadding: EdgeInsets.only(left: 8),
                    onDeleted: () {
                      setState(() {
                        tags.remove(tag);
                      });
                    },
                  ),
                );
              }).toList()
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, left: 16),
          child: Autocomplete<Tag>(
            displayStringForOption: (tag) => tag.name,
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
              _autocompleteTextEditController = textEditingController;
              return TextFormField(
                decoration: InputDecoration(
                  hintText: 'Añadir filtros...'
                ),
                controller: textEditingController,
                focusNode: focusNode,
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Tag>.empty();
              }
              return availableTags.where((Tag option) {
                return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) & !tags.contains(option);
              });
            },
            onSelected: (Tag tag) {
              setState(() {
                _autocompleteTextEditController.clear();
                if (tags.isEmpty) {
                  tags = [];
                }
                tags.add(tag);
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: ListTile(
            leading: IconButton(
              icon: Icon(Icons.edit_location_outlined, color: Colors.black,),
              onPressed: () {
                _locationModal(context);
              },
            ),
            minLeadingWidth: 0,
            title: Text('Cerca de: ' + (actualLocation ? 'Localización actual' : 'Posición en mapa')),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 40),
          child: ElevatedButton(onPressed: () {
            Navigator.pop(context, {'category': category, 'tags': tags});
          }, child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Aplicar filtros'),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
              Icon(Icons.send)
            ],
          )),
        )
      ],
    );
  }
}
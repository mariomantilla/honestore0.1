import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../models/category.dart';

import '../models/tag.dart';

class FilterSheet extends StatefulWidget {

  final Category category;
  final List<Tag> tags;
  final List<Category> availableCategories;
  final List<Tag> availableTags;
  final LocationData currentLocation;

  FilterSheet({Key key, this.category, this.tags, this.availableCategories, this.availableTags, this.currentLocation}) : super(key: key);

  @override
  _FilterSheetState createState() => _FilterSheetState(category: category, tags: tags, availableCategories: availableCategories, availableTags: availableTags, currentLocation: currentLocation);
}

class _FilterSheetState extends State<FilterSheet> {

  Category category;
  List<Tag> tags = [];
  final List<Category> availableCategories;
  List<Tag> availableTags = [];
  TextEditingController _autocompleteTextEditController;
  LocationData currentLocation;

  _FilterSheetState({this.category, this.tags, this.availableCategories, this.availableTags, this.currentLocation});

  @override
  Widget build(BuildContext context) {
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
               items: availableCategories.map<DropdownMenuItem<Category>>((cat) {return DropdownMenuItem(child: Text(cat.title), value: cat);}).toList()
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
            leading: Icon(Icons.location_on_outlined),
            minLeadingWidth: 0,
            title: Text('Cerca de: ' + (currentLocation != null ? 'Localización actual' : '?')),
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
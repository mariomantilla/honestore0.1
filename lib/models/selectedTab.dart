import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:honestore/models/category.dart' as models;



class SelectedTab extends ChangeNotifier {

  int selectedTab = 0;
  bool actualLocation = false;
  Location location = Location();
  LocationData currentLocation;

  List<models.Category> categories = [];

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

  SelectedTab() {
    data.asMap().forEach((index, element) {
      categories.add(models.Category(
          index,
          element['text'],
          AssetImage('images/categories/' + element['image']),
          []
      ));
    });
  }

  getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    actualLocation = true;
    changeLoc(await location.getLocation());

  }

  void changeLoc(LocationData loc) {
    currentLocation = loc;
    notifyListeners();
  }

  void changeTab(int tab) {
    selectedTab = tab;
    notifyListeners();
  }

}
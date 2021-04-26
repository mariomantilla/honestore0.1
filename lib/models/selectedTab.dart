import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:honestore/models/tag.dart';
import 'package:location/location.dart';
import 'package:honestore/services/backend.dart';
import 'package:honestore/models/category.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';



class SelectedTab extends ChangeNotifier {

  int selectedTab = 0;
  bool actualLocation = false;
  Location location = Location();
  LocationData currentLocation;

  List<models.Category> categories = [];
  List<Tag> tags = [];
  List<String> favourites = [];

  SelectedTab() {
    getLoc();
    getCategories();
    getTags();
    getFavourites();
  }

  getCategories() async {
    categories = await Backend().getCategories();
  }

  getTags() async {
    tags = await Backend().getTags();
  }

  getFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favourites = prefs.getStringList('favourites')??[];
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

  void toggleFav(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favourites.contains(id) ? favourites.remove(id) : favourites.add(id);
    await prefs.setStringList('favourites', favourites);
    notifyListeners();
  }

}
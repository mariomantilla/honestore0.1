import 'package:flutter/foundation.dart';


class SelectedTab extends ChangeNotifier {
  int selectedTab = 0;

  void changeTab(int tab) {
    selectedTab = tab;
    notifyListeners();
  }

}
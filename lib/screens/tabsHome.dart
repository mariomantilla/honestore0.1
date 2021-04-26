import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:honestore/screens/search.dart';
import 'package:honestore/styles/appTheme.dart';

import 'favourites.dart';


class TabItem {

  final String title;
  final IconData icon;
  final Widget body;
  final bool showBar;

  TabItem({this.title, this.icon, this.body, this.showBar = true});

}

class TabsHomePage extends StatefulWidget {

  static const routeName = '/';

  @override
  _TabsHomePageState createState() => _TabsHomePageState();
}

class _TabsHomePageState extends State<TabsHomePage> {

  int tab = 0;

  List<TabItem> pages = [
    TabItem(
      title: 'Buscar',
      icon: Icons.search,
      body: SearchPage(),
      showBar: false
    ),
    TabItem(
      title: 'Guardados',
      icon: FontAwesomeIcons.heart,
      body: FavouritesList()
    ),
    TabItem(
      title: 'Más',
      icon: Icons.more_horiz,
      body: Text('')
    ),
  ];

  @override
  Widget build(BuildContext context) {
    TabItem page = pages[tab];
    return Scaffold(
      appBar: page.showBar ? PreferredSize(
        preferredSize: Size.fromHeight(75.0),
        child: AppBar(
          title: Text(page.title,),
        ),
      ) : null,
      body: IndexedStack(
        index: tab,
        children: [for (var p in pages) p.body],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[for (var page in pages) BottomNavigationBarItem(
          icon: Icon(page.icon),
          label: page.title
        )],
        selectedItemColor: primaryColor,
        currentIndex: tab,
        onTap: (int index) {
          setState(() {
            tab = index;
          });
        },
      ),
    );
  }

}
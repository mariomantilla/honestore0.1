
import 'package:flutter/material.dart';

final primaryColor = Color(0xfffb7168);

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor,
  accentColor: primaryColor,
  fontFamily: 'Raleway',
  primaryTextTheme: TextTheme(
    headline6: TextStyle(
      color: Color(0xff333333),
      fontSize: 24,
      height: 3
    )
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.white),
      foregroundColor: MaterialStateProperty.all(Colors.black)
    )
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black
    )
  ),

  cardTheme: CardTheme(
    elevation: 2,
  )
);
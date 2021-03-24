
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  accentColor: Colors.black,
  highlightColor: Colors.amber,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.white),
      foregroundColor: MaterialStateProperty.all(Colors.black)
    )
  ),
  appBarTheme: AppBarTheme(
  brightness: Brightness.dark,
  ),
);
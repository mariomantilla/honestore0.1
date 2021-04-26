import 'package:flutter/material.dart';
import 'package:honestore/styles/appTheme.dart';

class ShadowIcon extends StatelessWidget {

  final IconData icon;
  final Color color;
  final double size;

  const ShadowIcon(this.icon, {Key key, this.color, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(size??24)),
      boxShadow: [
        BoxShadow(
          color: appTheme.canvasColor,
          spreadRadius: 7,
          blurRadius: 13,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Icon(icon, color: color, size: size),);
  }
}
import 'package:flutter/material.dart';

class Link extends StatelessWidget {

  final String text;
  final Function action;

  Link({Key key, this.text, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(text, style: TextStyle(
          color: Colors.blueGrey
      ),),
      onTap: action,
    );
  }
}
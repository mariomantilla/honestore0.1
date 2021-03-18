import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {

  final List<Widget> elements;

  Carousel({Key key, this.elements}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState(elements: elements);
}

class _CarouselState extends State<Carousel> {

  final List<Widget> elements;
  int page = 0;

  _CarouselState({this.elements});

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController();
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (int i) {
            setState(() {
              page = i;
            });
          },
          children: elements,
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            children: [for(var i=0; i<elements.length; i+=1) GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(bottom: 10, right: 2, left: 2),
                child: Icon(Icons.circle, size: 12, color: page == i ? Colors.black : Color(0x577000000),),
              ),
              onTap: () {
                _controller.animateToPage(i, duration: Duration(seconds: 1), curve: Curves.ease);
                setState(() {
                  page = i;
                });
              },
            )],
        )
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'carousel.dart';

class PicsCarousel extends StatelessWidget {

  final List<ImageProvider> images;
  final BoxFit fit;
  final bool pinch;

  PicsCarousel(this.images, {this.fit = BoxFit.fitWidth, this.pinch = false, Key key}) : super(key: key);

  Widget carouselElement(image) {
    return pinch ? PhotoView(
      imageProvider: image,
    ) : Image(
        fit: fit,
        image: image
    );
  }

  @override
  Widget build(BuildContext context) {
    return Carousel(
        elements: images.map((image) => carouselElement(image)).toList()
    );
  }
}

import 'package:flutter/widgets.dart';

/// Utilizado para posicionar elementos na tela de forma proporcional
/// Retonar elementos proporcionados baseados no tamanho da tela
class ProportionFactory {
  final Size screen;
  ProportionFactory(this.screen);

  Rect getRectLTRB(double left, double top, double right, double bottom) {
    return Rect.fromLTRB(
      left * screen.width,
      top * screen.height,
      right * screen.width, 
      bottom * screen.height
    );
  }

  Rect getRectLTWH(double left, double top, double width, double height) {
    return Rect.fromLTRB(
      left * screen.width, 
      top * screen.height, 
      (width + left) * screen.width, 
      (height + top) * screen.height
    );
  }
}

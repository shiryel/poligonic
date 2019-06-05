import 'package:flutter/material.dart';

/// Wraper para poder alterar os valores internos de um ponto dinamicamente
class Point {
  double dx;
  double dy;
  Point(this.dx, this.dy);
  Point.fromOffset(Offset offset) {
    dx = offset.dx;
    dy = offset.dy;
  }

  Offset toOffset() {
    return Offset(dx, dy);
  }
}
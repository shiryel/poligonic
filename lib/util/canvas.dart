import 'package:box2d_flame/box2d.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

Rect rectFromPositionComponent(PositionComponent c, Offset startP, Offset endP) {
  return Rect.fromPoints(
    Offset(c.width * startP.dx, c.height * startP.dy),
    Offset(c.width * endP.dx, c.height * endP.dy)
  );
}

Paint paintFromMaterial(MaterialColor color) {
  return Paint()
    ..color = color;
}
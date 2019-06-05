import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class HubSprite extends PositionComponent {
  final Sprite image;
  final Rect proportion;

  HubSprite(this.image, this.proportion);

  @override
  bool isHud() {
    return true;
  }

  @override
  void render(Canvas c) {
    image.renderRect(c, proportion);
  }

  @override
  void update(double t) {
  }
}
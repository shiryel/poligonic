import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void setInScreen(PositionComponent c, Size screen) {
  c.x = 0;
  c.y = 0;
  c.width = screen.width;
  c.height =screen.height;
}
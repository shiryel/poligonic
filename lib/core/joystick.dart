import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Joystick {
  final double sensibility;

  /// Controla um joystic de acordo com um timer, contado pelo [step]
  /// o [sensibility] define o quanto o joystick ira se mover na tela
  /// É recomendavel deixar o step a distancia mais longa / 20 e o sensibility a 1
  Joystick(this.sensibility);

  Offset _tapInput;
  double x = 0, y = 0;

  void tapInput(Offset action, Offset startPosition) {
    x = startPosition.dx;
    y = startPosition.dy;
    _tapInput = action;
  }

  Offset dragInput(Offset action) {
    var vx = _tapInput.dx - action.dx;
    var vy = _tapInput.dy - action.dy;
    _tapInput = action;
    x -= vx * sensibility;
    y -= vy * sensibility;

    return Offset(x,y);
  }
}
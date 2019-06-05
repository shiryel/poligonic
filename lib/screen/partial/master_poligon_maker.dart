import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:poligonic/component/master_poligon.dart';
import 'package:poligonic/component/poligon.dart';
import 'package:poligonic/core/colision_detector.dart';
import 'package:poligonic/core/joystick.dart';
import 'package:poligonic/core/ring_selector.dart';

class MasterPoligonMaker extends PositionComponent {
  var _ring = RingSelector<Poligon>();
  final Paint paint;
  final Rect area;
  final Joystick joystick;
  final String role;

  ColisionDetector get colision => ColisionDetector.fromRect(area);
  Poligon get selected => _ring.selected;

  MasterPoligonMaker.fromRect(this.area, MaterialColor color, this.role) :
    this.paint = Paint()..color = color,
    this.joystick = Joystick(1);

  @override
  void render(Canvas c) {
    _ring.list.forEach(
      (f) => f.render(c)
    );
  }

  @override
  void update(double t) {
  }

  void tapInput(Offset action) {
    if(_ring.selected != null) {
      var internalArea = _ring.selected.hitbox.colisionDetector.area;
      joystick.tapInput(action, Offset(internalArea.left, internalArea.top));
    }
  }

  void dragInput(Offset action) {
    if(_ring.selected != null) {
      var value = joystick.dragInput(action);
      var copy = _ring.selected.copy();
      copy.setPosition(value.dx, value.dy);
      if(copy.hitbox.colisionDetector.anyOutside(colision))
        return;
      else
        _ring.selected.setPosition(value.dx, value.dy);
    }
  }

  void killSelected() => _ring.removeSelected();

  void addStruct(Poligon p) => _ring.add(p);

  void moveSelected(int x) => _ring.moveIterator(x);

  void selectedToUp() => _ring.moveSelected(1);

  void selectedToDown() => _ring.moveSelected(-1);

  /// Pega o poligono com base no tamanho que ele ocupa
  MasterPoligon make() {
    return MasterPoligon.makeFromPoligons(_ring.list, role, null, 0);
  }

  /// Pega o poligono com base no tamanho que ocupa e posiciona em uma area, se nenhuma area for informada ele usa a area interna deste [maker]
  MasterPoligon makePositioned([Rect area]) {
    area ??= area;
    return MasterPoligon.makeFromPoligons(_ring.list, role, null, 0, area);
  }
}